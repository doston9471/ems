# GraphQL

- Endpoint: `POST /graphql`
- Development IDE: `/graphiql` (development only)
- Auth: session cookie **or** `Authorization: Bearer <jwt>`
- Tenancy: optional `X-Company-Id` header

## Me + company directory

```graphql
query Directory {
  me {
    id
    emailAddress
    fullName
  }
  employees {
    id
    employeeNumber
    fullName
    email
    jobTitle
    employmentStatus
    department {
      id
      name
    }
  }
  departments {
    id
    name
    code
    active
  }
}
```

```bash
curl -s http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <jwt>" \
  -H "X-Company-Id: 1" \
  -d '{"query":"{ me { fullName } employees { fullName } }"}'
```

## Single employee

```graphql
query Employee($id: ID!) {
  employee(id: $id) {
    id
    fullName
    salaryCents
    currency
  }
}
```

## Mutations

### Clock in

```graphql
mutation {
  clockIn(input: {}) {
    attendanceDay {
      id
      workDate
      status
      clockInAt
    }
    errors
  }
}
```

### Submit leave request

```graphql
mutation SubmitLeave($leaveTypeId: ID!, $startOn: ISO8601Date!, $endOn: ISO8601Date!) {
  submitLeaveRequest(
    input: {
      leaveTypeId: $leaveTypeId
      startOn: $startOn
      endOn: $endOn
      reason: "Family trip"
    }
  ) {
    leaveRequest {
      id
      status
      startOn
      endOn
      days
    }
    errors
  }
}
```
