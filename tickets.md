# Lab ticket log

### REQ-1013-1059 · Password reset for Sam Rivera (P4 Service request)
- **Reported by:** Sam Rivera
- **Impact / urgency:** Low / Medium = P4
- **Symptoms:** User forgot password
- **Investigation:** Verified user's identity before making changes.
Checked the account with "Get-ADUser Srivera -Properties LockedOut -> Which showed it wasnt locked

So did a reset
- **Root cause:** Forgotten password
- **Resolution:** Reset in ADUC. Reset in next login
- **Prevention / follow-up:** Suggested password manager. Self service password reset would cut  tickets like this
- **Time spent:** 10 min · **Lab quest:** Q03

### INC-1013-1337 · Account Locked out: Sam Rivera (P3 Incident)
- **Reported by:** Sam Rivera
- **Impact / urgency:** Medium / Medium = P3
- **Symptoms:** "The reference account is currently locked out and may not be logged on to"
- **Investigation:** Search-ADAccount -LockedOut showed srivera. Get-ADUser showed BadLogonCount 5 and the last bad attempt at 1:20:12 PM. Security event 4740 on DC01 at 1:20:12 PM named the caller computer as CLIENT01.
- **Root cause:** Five wrong passwords entered at CLIENT01, which triggered the new lockout policy (5 attempts, 15 minutes). This was a lab test of that policy.
- **Resolution:** Verified the user’s identity, ran Unlock-ADAccount, confirmed LockedOut was False, and the user signed in successfully.
- **Prevention / follow-up:** If lockouts repeat, check event 4740’s caller computer for devices still using an old password, such as a phone or a mapped drive.
- **Time spent:** n/a · **Lab quest:** Q04
