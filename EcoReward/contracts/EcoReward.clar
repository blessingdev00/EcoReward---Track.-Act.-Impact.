;; EcoReward - Track. Act. Impact.
;; A decentralized environmental impact tracking and reward platform
;; Features: Carbon tracking, green actions, sustainability rewards

;; ===================================
;; CONSTANTS AND ERROR CODES
;; ===================================

(define-constant ERR-NOT-AUTHORIZED (err u80))
(define-constant ERR-ACTION-NOT-FOUND (err u81))
(define-constant ERR-INVALID-AMOUNT (err u82))
(define-constant ERR-ALREADY-CLAIMED (err u83))
(define-constant ERR-INSUFFICIENT-IMPACT (err u84))

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-DAILY-ACTIONS u10)
(define-constant MIN-REWARD-THRESHOLD u100)
(define-constant VERIFICATION-PERIOD u144) ;; ~1 day

;; ===================================
;; DATA VARIABLES
;; ===================================

(define-data-var platform-active bool true)
(define-data-var action-counter uint u0)
(define-data-var total-impact-points uint u0)
(define-data-var total-rewards-distributed uint u0)

;; ===================================
;; TOKEN DEFINITIONS
;; ===================================

;; Green impact tokens
(define-fungible-token green-token)

;; ===================================
;; DATA MAPS
;; ===================================

;; Environmental actions
(define-map eco-actions
  uint
  {
    name: (string-ascii 64),
    description: (string-ascii 128),
    impact-points: uint,
    reward-amount: uint,
    category: (string-ascii 32),
    verification-required: bool,
    active: bool
  }
)

;; User environmental impact
(define-map user-impact
  principal
  {
    total-points: uint,
    total-rewards: uint,
    actions-completed: uint,
    green-level: uint,
    last-activity: uint
  }
)

;; Daily user activities
(define-map daily-activities
  { user: principal, day: uint }
  {
    actions-today: uint,
    points-earned: uint,
    rewards-claimed: uint
  }
)

;; Action submissions
(define-map action-submissions
  uint
  {
    user: principal,
    action-id: uint,
    evidence-hash: (string-ascii 64),
    submitted-at: uint,
    verified: bool,
    points-awarded: uint
  }
)

;; Impact leaderboard
(define-map impact-rankings
  uint
  {
    user: principal,
    total-impact: uint,
    rank-period: uint
  }
)

;; ===================================
;; PRIVATE HELPER FUNCTIONS
;; ===================================

(define-private (is-contract-owner (user principal))
  (is-eq user CONTRACT-OWNER)
)

(define-private (get-current-day)
  (/ burn-block-height VERIFICATION-PERIOD)
)

(define-private (calculate-green-level (total-points uint))
  (if (<= total-points u100) u1
    (if (<= total-points u500) u2
      (if (<= total-points u1000) u3
        (if (<= total-points u2500) u4 u5)
      )
    )
  )
)

(define-private (can-submit-action (user principal))
  (let (
    (current-day (get-current-day))
    (daily-data (default-to { actions-today: u0, points-earned: u0, rewards-claimed: u0 }
                            (map-get? daily-activities { user: user, day: current-day })))
  )
    (< (get actions-today daily-data) MAX-DAILY-ACTIONS)
  )
)

;; ===================================
;; READ-ONLY FUNCTIONS
;; ===================================

(define-read-only (get-platform-info)
  {
    active: (var-get platform-active),
    total-actions: (var-get action-counter),
    total-impact: (var-get total-impact-points),
    total-rewards: (var-get total-rewards-distributed)
  }
)

(define-read-only (get-eco-action (action-id uint))
  (map-get? eco-actions action-id)
)

(define-read-only (get-user-impact (user principal))
  (map-get? user-impact user)
)

(define-read-only (get-daily-activity (user principal) (day uint))
  (map-get? daily-activities { user: user, day: day })
)

(define-read-only (get-action-submission (submission-id uint))
  (map-get? action-submissions submission-id)
)

(define-read-only (get-user-rank (user principal) (period uint))
  (map-get? impact-rankings period)
)

;; ===================================
;; ADMIN FUNCTIONS
;; ===================================

(define-public (toggle-platform (active bool))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (var-set platform-active active)
    (print { action: "platform-toggled", active: active })
    (ok true)
  )
)

(define-public (create-eco-action
  (name (string-ascii 64))
  (description (string-ascii 128))
  (impact-points uint)
  (reward-amount uint)
  (category (string-ascii 32))
  (verification-required bool)
)
  (let (
    (action-id (+ (var-get action-counter) u1))
  )
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> impact-points u0) ERR-INVALID-AMOUNT)
    (asserts! (> reward-amount u0) ERR-INVALID-AMOUNT)
    
    ;; Create eco action
    (map-set eco-actions action-id {
      name: name,
      description: description,
      impact-points: impact-points,
      reward-amount: reward-amount,
      category: category,
      verification-required: verification-required,
      active: true
    })
    
    (var-set action-counter action-id)
    (print { action: "eco-action-created", action-id: action-id, name: name, points: impact-points })
    (ok action-id)
  )
)

(define-public (fund-reward-pool (amount uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    (try! (ft-mint? green-token amount (as-contract tx-sender)))
    (print { action: "reward-pool-funded", amount: amount })
    (ok true)
  )
)

;; ===================================
;; ECO ACTION FUNCTIONS
;; ===================================

(define-public (submit-eco-action
  (action-id uint)
  (evidence-hash (string-ascii 64))
)
  (let (
    (action-data (unwrap! (map-get? eco-actions action-id) ERR-ACTION-NOT-FOUND))
    (submission-id (+ (var-get action-counter) u1000))
    (current-day (get-current-day))
    (user-stats (default-to { total-points: u0, total-rewards: u0, actions-completed: u0, green-level: u0, last-activity: u0 }
                            (map-get? user-impact tx-sender)))
    (daily-data (default-to { actions-today: u0, points-earned: u0, rewards-claimed: u0 }
                            (map-get? daily-activities { user: tx-sender, day: current-day })))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (get active action-data) ERR-ACTION-NOT-FOUND)
    (asserts! (can-submit-action tx-sender) ERR-INSUFFICIENT-IMPACT)
    
    ;; Create submission record
    (map-set action-submissions submission-id {
      user: tx-sender,
      action-id: action-id,
      evidence-hash: evidence-hash,
      submitted-at: burn-block-height,
      verified: (not (get verification-required action-data)),
      points-awarded: (get impact-points action-data)
    })
    
    ;; If no verification required, award points immediately
    (if (not (get verification-required action-data))
      (begin
        ;; Update user impact
        (let (
          (new-total-points (+ (get total-points user-stats) (get impact-points action-data)))
          (new-green-level (calculate-green-level new-total-points))
        )
          (map-set user-impact tx-sender (merge user-stats {
            total-points: new-total-points,
            actions-completed: (+ (get actions-completed user-stats) u1),
            green-level: new-green-level,
            last-activity: burn-block-height
          }))
        )
        
        ;; Update daily activity
        (map-set daily-activities { user: tx-sender, day: current-day } {
          actions-today: (+ (get actions-today daily-data) u1),
          points-earned: (+ (get points-earned daily-data) (get impact-points action-data)),
          rewards-claimed: (get rewards-claimed daily-data)
        })
        
        ;; Update global stats
        (var-set total-impact-points (+ (var-get total-impact-points) (get impact-points action-data)))
      )
      true
    )
    
    (print { action: "eco-action-submitted", submission-id: submission-id, user: tx-sender, action-id: action-id })
    (ok submission-id)
  )
)

(define-public (verify-submission (submission-id uint) (approved bool))
  (let (
    (submission-data (unwrap! (map-get? action-submissions submission-id) ERR-ACTION-NOT-FOUND))
    (action-data (unwrap! (map-get? eco-actions (get action-id submission-data)) ERR-ACTION-NOT-FOUND))
    (user-stats (default-to { total-points: u0, total-rewards: u0, actions-completed: u0, green-level: u0, last-activity: u0 }
                            (map-get? user-impact (get user submission-data))))
  )
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (get verified submission-data)) ERR-ALREADY-CLAIMED)
    (asserts! (get verification-required action-data) ERR-ACTION-NOT-FOUND)
    
    ;; Mark as verified
    (map-set action-submissions submission-id (merge submission-data { verified: approved }))
    
    ;; If approved, award points
    (if approved
      (let (
        (new-total-points (+ (get total-points user-stats) (get points-awarded submission-data)))
        (new-green-level (calculate-green-level new-total-points))
      )
        (map-set user-impact (get user submission-data) (merge user-stats {
          total-points: new-total-points,
          actions-completed: (+ (get actions-completed user-stats) u1),
          green-level: new-green-level,
          last-activity: burn-block-height
        }))
        
        ;; Update global stats
        (var-set total-impact-points (+ (var-get total-impact-points) (get points-awarded submission-data)))
      )
      true
    )
    
    (print { action: "submission-verified", submission-id: submission-id, approved: approved })
    (ok true)
  )
)

(define-public (claim-rewards)
  (let (
    (user-stats (unwrap! (map-get? user-impact tx-sender) ERR-ACTION-NOT-FOUND))
    (reward-amount (/ (get total-points user-stats) u10))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (>= (get total-points user-stats) MIN-REWARD-THRESHOLD) ERR-INSUFFICIENT-IMPACT)
    (asserts! (> reward-amount u0) ERR-INVALID-AMOUNT)
    
    ;; Transfer rewards to user
    (try! (as-contract (ft-transfer? green-token reward-amount tx-sender tx-sender)))
    
    ;; Update user stats
    (map-set user-impact tx-sender (merge user-stats {
      total-rewards: (+ (get total-rewards user-stats) reward-amount)
    }))
    
    ;; Update global stats
    (var-set total-rewards-distributed (+ (var-get total-rewards-distributed) reward-amount))
    
    (print { action: "rewards-claimed", user: tx-sender, amount: reward-amount })
    (ok reward-amount)
  )
)

(define-public (update-leaderboard (period uint))
  (let (
    (user-stats (unwrap! (map-get? user-impact tx-sender) ERR-ACTION-NOT-FOUND))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (> (get total-points user-stats) u0) ERR-INSUFFICIENT-IMPACT)
    
    ;; Update ranking for period
    (map-set impact-rankings period {
      user: tx-sender,
      total-impact: (get total-points user-stats),
      rank-period: period
    })
    
    (print { action: "leaderboard-updated", user: tx-sender, period: period, impact: (get total-points user-stats) })
    (ok true)
  )
)

(define-public (create-impact-challenge
  (challenge-name (string-ascii 64))
  (target-points uint)
  (reward-multiplier uint)
)
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> target-points u0) ERR-INVALID-AMOUNT)
    (asserts! (> reward-multiplier u0) ERR-INVALID-AMOUNT)
    
    ;; For simplicity, just mint bonus tokens to contract for challenges
    (try! (ft-mint? green-token (* target-points reward-multiplier) (as-contract tx-sender)))
    
    (print { action: "impact-challenge-created", name: challenge-name, target: target-points, multiplier: reward-multiplier })
    (ok true)
  )
)

;; ===================================
;; INITIALIZATION
;; ===================================

(begin
  ;; Create initial eco actions
  (map-set eco-actions u1 { name: "Use Public Transport", description: "Take public transport instead of driving", impact-points: u10, reward-amount: u5, category: "Transport", verification-required: false, active: true })
  (map-set eco-actions u2 { name: "Plant a Tree", description: "Plant and care for a tree", impact-points: u50, reward-amount: u25, category: "Nature", verification-required: true, active: true })
  (map-set eco-actions u3 { name: "Recycle Waste", description: "Properly recycle household waste", impact-points: u15, reward-amount: u8, category: "Waste", verification-required: false, active: true })
  (var-set action-counter u3)
  
  (print "EcoReward Platform Initialized")
  (print "Track. Act. Impact.")
)