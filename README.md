# 🌱 EcoReward - Track. Act. Impact.

A decentralized environmental impact tracking and reward platform built on Stacks blockchain that incentivizes sustainable actions through gamification and green token rewards.

## 📋 Overview

EcoReward transforms environmental action into measurable impact by rewarding users with green tokens for completing verified sustainable activities. Build your green profile, compete on leaderboards, and earn rewards for positive environmental actions.

## ✨ Key Features

### 🌍 Environmental Action Tracking
- Pre-defined eco-friendly actions with impact point values
- Custom action categories (Transport, Nature, Waste, Energy)
- Verification system for high-impact activities
- Daily action limits to encourage consistent behavior

### 🏆 Gamification & Rewards
- Green level progression system (Level 1-5)
- Impact point accumulation and leaderboards
- Green token rewards based on accumulated points
- Challenge creation for community engagement

### 📊 Impact Analytics
- Personal impact tracking and history
- Daily activity monitoring and streaks
- Community leaderboard rankings
- Global platform impact metrics

### 🎯 Community Challenges
- Admin-created impact challenges with bonus rewards
- Multiplier rewards for challenge participation
- Period-based ranking competitions
- Social impact verification and recognition

## 🏗️ Architecture

### Core Components
```clarity
eco-actions        -> Available environmental actions and rewards
user-impact        -> Personal environmental impact tracking
daily-activities   -> Daily action limits and progress
action-submissions -> Verification queue for high-impact actions
impact-rankings    -> Community leaderboard and competitions
```

### Impact Flow
1. **Action Selection**: Users choose from available eco-actions
2. **Submission**: Submit evidence for verification if required
3. **Verification**: Admin verifies high-impact submissions
4. **Reward**: Automatic point and token rewards
5. **Progression**: Green level advancement and leaderboard updates

## 🚀 Getting Started

### For Eco-Warriors

1. **Start Acting**: Submit environmental actions for points
   ```clarity
   (submit-eco-action action-id evidence-hash)
   ```

2. **Track Progress**: Monitor your environmental impact
   ```clarity
   (get-user-impact user-address)
   ```

3. **Claim Rewards**: Exchange points for green tokens
   ```clarity
   (claim-rewards)
   ```

4. **Compete**: Update leaderboard rankings
   ```clarity
   (update-leaderboard period)
   ```

### For Platform Administrators

1. **Create Actions**: Define new environmental activities
   ```clarity
   (create-eco-action name description points reward category verification)
   ```

2. **Verify Submissions**: Approve high-impact action claims
   ```clarity
   (verify-submission submission-id approved)
   ```

3. **Fund Rewards**: Add green tokens to reward pool
   ```clarity
   (fund-reward-pool amount)
   ```

## 📈 Example Scenarios

### Daily Sustainable Living
```
1. Sarah takes public transport to work: +10 impact points
2. Recycles household waste properly: +15 impact points
3. Uses reusable water bottle: +5 impact points
4. Daily total: 30 points toward green token rewards
5. Reaches Level 2 Green Warrior status after 1 week
```

### Community Tree Planting
```
1. Alex plants tree in local park: submits with photo evidence
2. Admin verifies legitimate tree planting: +50 impact points
3. Qualifies for "Tree Planter" challenge bonus: +25 extra points
4. Total 75 points moves Alex up community leaderboard
5. Earns green tokens for significant environmental contribution
```

### Monthly Impact Challenge
```
1. Platform launches "Plastic-Free Month" challenge
2. Users complete plastic reduction actions for bonus multipliers
3. Top 10 participants earn additional reward tokens
4. Community collectively saves 1,000+ plastic items
5. Global impact metrics show measurable environmental benefit
```

## ⚙️ Configuration

### Action System
- **Daily Action Limit**: 10 actions per user per day
- **Green Levels**: 1-5 based on total impact points
- **Reward Threshold**: 100 minimum points for token claiming
- **Verification Period**: ~1 day for admin review

### Token Economics
- **Reward Rate**: 1 green token per 10 impact points
- **Challenge Multipliers**: Admin-set bonus rewards
- **Point Categories**: Transport (5-15), Nature (25-75), Waste (10-20), Energy (15-40)

## 🔒 Security Features

### Action Verification
- Two-tier system: instant rewards for simple actions, verification for high-impact
- Evidence submission prevents fraudulent claims
- Admin oversight ensures legitimate environmental impact
- Daily limits prevent gaming and encourage sustained behavior

### Token Distribution
- Minimum point thresholds prevent spam claims
- Controlled token minting by admins
- Transparent reward calculations
- Platform fee-free token distribution

### Error Handling
```clarity
ERR-NOT-AUTHORIZED (u80)      -> Insufficient permissions
ERR-ACTION-NOT-FOUND (u81)    -> Invalid action or submission ID
ERR-INVALID-AMOUNT (u82)      -> Invalid points or reward amounts
ERR-ALREADY-CLAIMED (u83)     -> Action already verified or claimed
ERR-INSUFFICIENT-IMPACT (u84) -> Not enough points for operation
```

## 📊 Analytics

### Platform Metrics
- Total environmental actions completed
- Global impact points accumulated
- Green tokens distributed to users
- Community participation rates

### User Progress
- Personal impact point accumulation
- Green level progression tracking
- Daily action streaks and consistency
- Challenge participation and success

### Environmental Impact
- Category-wise action distribution
- Community-wide sustainability metrics
- Verification rates and quality
- Challenge effectiveness and engagement

## 🛠️ Development

### Prerequisites
- Clarinet CLI installed
- Understanding of environmental impact measurement
- Green token economics for rewards

### Local Testing
```bash
# Validate contract
clarinet check

# Run environmental tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

### Integration Examples
```clarity
;; Submit simple eco action
(contract-call? .ecoreward submit-eco-action u1 "")

;; Submit tree planting with evidence
(contract-call? .ecoreward submit-eco-action u2 "QmTreePhoto123")

;; Admin verifies high-impact action
(contract-call? .ecoreward verify-submission u1001 true)

;; Claim accumulated green token rewards
(contract-call? .ecoreward claim-rewards)

;; Check personal environmental impact
(contract-call? .ecoreward get-user-impact tx-sender)
```

## 🎯 Use Cases

### Personal Sustainability
- Daily eco-action tracking and habit building
- Environmental impact measurement and goals
- Reward-based motivation for green behavior
- Progress sharing and community accountability

### Educational Programs
- School environmental education and engagement
- Corporate sustainability training and tracking
- Community environmental awareness campaigns
- Gamified learning about environmental impact

### Community Initiatives
- Local environmental challenge coordination
- Neighborhood sustainability competitions
- Environmental group activity tracking
- Collective impact measurement and reporting

## 📋 Quick Reference

### Core Functions
```clarity
;; Action Management
submit-eco-action(action-id, evidence-hash) -> submission-id
verify-submission(submission-id, approved) -> success
create-eco-action(name, description, points, reward, category, verification) -> action-id

;; Rewards & Progress
claim-rewards() -> reward-amount
update-leaderboard(period) -> success
create-impact-challenge(name, target-points, multiplier) -> success

;; Information Queries
get-eco-action(action-id) -> action-data
get-user-impact(user) -> impact-data
get-daily-activity(user, day) -> activity-data
```

## 🚦 Deployment Guide

1. Deploy contract with initial eco-actions
2. Fund green token reward pool
3. Launch with environmental education campaign
4. Create engaging impact challenges
5. Monitor community participation and impact
6. Scale action categories based on user feedback

## 🤝 Contributing

EcoReward welcomes community contributions:
- New environmental action suggestions
- Impact measurement methodology improvements
- Gamification and engagement enhancements
- Real-world environmental impact validation

---

**⚠️ Disclaimer**: EcoReward is environmental gamification software. Ensure proper verification processes and understand that digital rewards complement but don't replace actual environmental impact.
