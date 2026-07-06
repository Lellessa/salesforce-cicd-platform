## 🔐 Salesforce CI/CD Integration Setup

Follow these steps to configure a Salesforce organization for authentication with the CI/CD pipeline using the JWT Bearer Flow.

### 1. Create the Permission Set

Create a new Permission Set with the following configuration:

| Property | Value |
|----------|-------|
| Name | `JWT Access` |

Enable the following permissions:

- **API Only User**
- **Modify All Data**

---

### 2. Create the CI/CD Integration User

Create a dedicated integration user for the pipeline.

| Property | Value |
|----------|-------|
| Name | CI/CD Pipeline Integration |
| Username | `pipeline.integration@your-domain.<environment>` |
| Email | A shared technical email address |
| Profile | System Administrator |

After creating the user, assign the **JWT Access** permission set.

> **Recommendation:** Use a dedicated integration user that is not associated with any individual developer.

---

### 3. Generate the JWT Certificate

Generate a private key:

```bash
openssl genrsa -out server.key 2048
```

Generate a self-signed certificate:

```bash
openssl req -new -x509 -key server.key -sha256 -out server.crt
```

Store the generated files securely:

- `server.key` → **Never commit to Git**
- `server.crt`

---

### 4. Create the External Client App

Create an External Client App with the following configuration.

#### General

| Property | Value |
|----------|-------|
| Name | CI/CD Platform |
| Contact Email | Shared technical email |

#### OAuth Settings

Callback URL:

```
https://login.salesforce.com/services/oauth2/success
```

OAuth Scopes:

- Manage user data via APIs (`api`)
- Full access (`full`)
- Perform requests at any time (`refresh_token`, `offline_access`)

Additional settings:

- ✅ Enable JWT Bearer Flow
- Upload the generated `server.crt`

#### Policies

Configure the following:

| Setting | Value |
|---------|-------|
| Permitted Users | Admin approved users are pre-authorized |
| Pre-authorized Permission Set | JWT Access |

---

### 5. Configure the GitHub Environment

Create one GitHub Environment for each Salesforce enviroment.

Examples:

- `dev`
- `it`
- `qa`
- `prod`

#### Secrets

| Name | Description |
|------|-------------|
| `JWT_KEY` | Contents of `server.key` |

#### Variables

| Name | Example |
|------|---------|
| `CONSUMER_KEY` | Consumer Key from the External Client App |
| `ORG_ALIAS` | `dev`, `it`, `qa`, or `prod` |
| `TEST_LEVEL` | e.g. `RunLocalTests` |
| `URL` | `https://login.salesforce.com` (or your My Domain URL if applicable) |
| `USERNAME` | `pipeline.integration@your-domain.prod` |

---

## Security Recommendations

- Never commit `server.key` to the repository.
- Store all sensitive values as GitHub Secrets.
- Use a dedicated integration user instead of a personal account.
- Rotate certificates and credentials periodically.
- Grant only the permissions required for the pipeline to operate.
