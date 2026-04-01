# First Principles Workflow

A methodology for breaking down complex security problems, systems, or architectures into their fundamental truths, questioning every assumption, and rebuilding understanding from the ground up.

## The Problem with Analogy

Most security thinking is reasoning by analogy: "We secure this API the same way we secured the last one," or "We need EDR because everyone uses EDR." This leads to inheriting the flaws, limitations, and bloated assumptions of past solutions.

First principles thinking discards analogy. It forces you to look at the raw physics of a system: what is actually happening, what is mathematically possible, and what is strictly necessary.

---

## The Four-Step Decomposition

Apply this process to vulnerability assessment, defense design, incident response, or threat modeling.

### 1. Identify the Core Problem
Clearly state the problem or system being analyzed without using industry jargon or assumed solutions.

*   **Bad (Analogy):** "We need to deploy a WAF to stop SQL injection."
*   **Good (First Principles):** "We need to ensure that user-provided text cannot alter the structure of database queries."

### 2. Deconstruct into Fundamental Truths
Break the system down until you reach facts that cannot be reasonably questioned. Strip away vendor claims, "best practices," and conventional wisdom.

What are the raw components? (Data, compute, network paths, cryptographic primitives, human behavior).

*   **System:** A web application authenticating users.
*   **Fundamental Truths:**
    1. The server must verify the client holds a secret.
    2. The secret must be transmitted over a network.
    3. The network is untrusted and observable.
    4. The server must store something to validate the secret.
    5. The client must store the secret or a derivative (cookie/token) between requests.

### 3. Question Every Assumption
Look at the fundamental truths and ruthlessly interrogate the assumptions holding them together.

*   *Truth 2:* The secret must be transmitted.
    *   *Assumption:* The secret must be the password itself.
    *   *Question:* Does it? Could it be a cryptographic proof of possession (like WebAuthn) instead?
*   *Truth 4:* The server must store something to validate the secret.
    *   *Assumption:* The server stores a hash of the password.
    *   *Question:* What happens if the database is stolen? The hashes can be cracked.
    *   *Assumption:* Cracking is slow because we use bcrypt.
    *   *Question:* What if the attacker has massive GPU resources? The fundamental truth is that storing any derivative of a shared secret creates a target.

### 4. Rebuild from the Ground Up
Construct a new solution or understanding based *only* on the verified fundamental truths, completely ignoring how it is "usually done."

*   **The Rebuilt Solution (Authentication):** Instead of transmitting and hashing passwords (the analogy approach), we eliminate the shared secret entirely. The server stores only public keys. The client proves identity by signing a challenge with a private key stored in a hardware enclave (WebAuthn/Passkeys). The database can be fully compromised, and the attacker gains nothing they can use to log in.

---

## Applied First Principles

### Application: Vulnerability Assessment (Finding 0-days)
Don't just run a scanner. Break the application down.

1.  **Truth:** This application parses XML input.
2.  **Truth:** The XML standard supports external entity definitions (XXE).
3.  **Assumption:** The developer disabled external entity resolution in their chosen XML parsing library.
4.  **Action:** Test the assumption. Submit an XXE payload. If the assumption is false, you have a vulnerability. The fundamental truth is that the parser will follow the standard unless explicitly told not to.

### Application: Defense Design (Zero Trust)
Don't buy a "Zero Trust" product. Build the concept.

1.  **Problem:** Users need access to internal apps while remote.
2.  **Analogy Solution:** VPN. Once inside the perimeter, they are trusted.
3.  **Fundamental Truths:**
    *   The network boundary is an illusion.
    *   A device's physical location does not guarantee its integrity.
    *   An IP address is not an identity.
4.  **Rebuilt Solution:** We must evaluate identity, device health, and context on *every single request* to *every single application*, regardless of network location. The network is irrelevant; the access policy engine is everything.

### Application: Incident Response
Don't just follow the playbook blindly.

1.  **Problem:** High CPU usage on a database server; suspected cryptominer.
2.  **Analogy Reaction:** Kill the process, run AV, reboot.
3.  **Fundamental Truths:**
    *   The miner binary had to be written to disk or memory.
    *   The attacker needed a mechanism to execute it.
    *   The attacker needed initial access to deploy that mechanism.
4.  **Rebuilt Reaction:** If we just kill the miner, the attacker still has their initial access and execution mechanism. We must first identify the delivery vector (e.g., an unpatched vulnerability in the web application fronting the database) before alerting the attacker that we are watching.

---

## The "5 Whys" Technique

When identifying fundamental truths, repeatedly ask "Why?" until you hit a physical, mathematical, or logical absolute.

1.  **Observation:** The system was breached via SQL injection.
    *   *Why?* The WAF didn't block the payload.
    *   *Why?* The payload was heavily obfuscated, bypassing the regex rules.
    *   *Why do we rely on regex rules?* Because we are trying to filter bad input.
    *   *Why are we filtering input?* Because the input is being concatenated directly into the SQL query string.
    *   *Why is it concatenated?* Because we aren't using parameterized queries.
    *   **Fundamental Truth:** Concatenating untrusted data into an interpreter context is mathematically insecure. The WAF was a band-aid on a fundamental physics problem. The root fix is parameterization.
