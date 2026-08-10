#import "/template/lib.typ": *

#show: assignment.with(
  title: "Security Features in Real World Applications",
  number: "Assignment 01",
  kind: "Theory",
  course: "Cryptology",
)

= Security features in real-world applications
Five online services to determine their core security features. We identify the primary goal for each application and also details the exact mechanism and protocol running behind the scenes.

#figure(
  caption: [Security feature, mechanism and protocol for five everyday applications],
  {
    set text(9.5pt)
    table(
      columns: (1fr, 1fr, 1.3fr, 1.3fr, 2.1fr),
      align: (left, left, left, left, left),
      table.header(
        [Application], [Security Feature], [Security Mechanism], [Protocol or Technology], [How it provides security],
      ),
      [Gmail], [Authentication], [Password and 2 Step Verification], [OAuth 2.0, TOTP],
      [The system confirms user identity. A one time code ensures a stolen password alone fails to grant access.],
      [PhonePe], [Confidentiality], [Encryption and UPI PIN], [TLS 1.3, UPI],
      [Payment data travels as ciphertext. Network eavesdroppers see nothing useful. The PIN keeps the payment private to the account holder.],
      [GitHub], [Integrity], [Hashing and commit signing], [Git SHA 256, SSH signatures],
      [Every commit gets a content hash. Any unauthorized code change leaves a trace. A signature proves the commit came from the correct author.],
      [Discord], [Authorization], [Role based permissions], [RBAC, OAuth 2.0 scopes],
      [Server roles determine member actions. Users only receive their explicitly granted access.],
      [YouTube], [Availability], [Redundancy and DDoS mitigation], [CDN, load balancing],
      [Edge servers serve the video content. Traffic filtering runs in front. The site stays reachable under heavy load or attack.],
    )
  },
)

#pagebreak()

= Security controls classified by CIA and the prevent, detect, recover cycle
The core controls for these applications fall into Confidentiality, Integrity, or Availability. The following table outlines how these mechanisms stop data attacks. We map out the exact steps these services take to detect breaches and recover their systems.

#figure(
  caption: [Controls classified by CIA, mapped to prevent, detect and recover],
  {
    set text(9.5pt)
    table(
      columns: (0.9fr, 1.5fr, 1.5fr, 1.5fr, 1.5fr),
      align: (left, left, left, left, left),
      table.header(
        [Application], [Control and protocol], [Prevent], [Detect], [Recover],
      ),
      [Gmail],
      [Confidentiality and Authentication: TLS, 2FA],
      [Encryption and a second factor block eavesdropping and stolen password logins.],
      [Sign in alerts flag unfamiliar logins.],
      [Account recovery and a forced password reset restore access.],
      [PhonePe],
      [Confidentiality and Integrity: TLS, UPI PIN],
      [Encrypted PIN locked transactions stop unauthorized payments.],
      [Fraud monitoring flags unusual transactions.],
      [Dispute reversal and device deregistration undo the damage.],
      [GitHub],
      [Integrity and Authorization: hashing, RBAC],
      [Repo permissions block unauthorized pushes to protected branches.],
      [Signed commit checks and audit logs reveal tampering.],
      [A git revert and clean clones restore the correct history.],
      [Discord],
      [Authorization and Availability: roles, rate limiting],
      [Role permissions and rate limits restrict abuse.],
      [The audit log records admin actions for review.],
      [Admins reassign roles, ban offenders, and restore from a backup.],
      [YouTube],
      [Availability: CDN, redundancy, DDoS filtering],
      [Load balancing absorbs traffic surges before they overwhelm servers.],
      [Traffic monitoring spots spikes and attack patterns early.],
      [Failover to healthy data centers keeps the service running.],
    )
  },
)
