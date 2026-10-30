The fundamental difference between Continuous Delivery and Continuous Deployment is whether releasing to production requires a separate human decision or happens automatically.

| Aspect             | Continuous Delivery                                         | Continuous Deployment                            |
| ------------------ | ----------------------------------------------------------- | ------------------------------------------------ |
| Goal               | Software is always ready for production                     | Software is automatically released to production |
| Production release | Requires a separate release decision, often manual approval | Automatic after all required checks pass         |
| Human intervention | Required to initiate or authorize production release        | Not required for each successful release         |
| Automation         | Build, test, and prepare for release                        | Build, test, and release to production           |
| Key principle      | Ready to deploy anytime                                     | Deploy automatically when ready                  |

### Example

Continuous Delivery

```
Developer pushes code
        ↓
Jenkins Build
        ↓
Automated Tests
        ↓
Release Artifact Ready
        ↓
Manual Release Decision
        ↓
Production Deployment
```

Continuous Deployment

```
Developer pushes code
        ↓
Jenkins Build
        ↓
Automated Tests
        ↓
All Required Checks Pass
        ↓
Automatic Production Deployment
```

### Important nuance

Continuous Delivery does not necessarily mean clicking a manual approval button in Jenkins. That is just one implementation.

Continuous Delivery means the software is kept in a deployable state, while the production release is a separately controlled decision.

Continuous Deployment goes one step further: every change that passes the required automated pipeline is released to production without a per-release human approval.

In one sentence:

- Continuous Delivery: We can deploy at any time.
- Continuous Deployment: We automatically do deploy every qualifying change.

Both can use Jenkins, Maven, Docker, and the same automated testing processes. The defining difference is the production release policy, not the tools.
