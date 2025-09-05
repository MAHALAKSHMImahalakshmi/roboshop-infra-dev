# roboshop-infra-dev
```mermaid
flowchart LR
  %% External Users
  UserBrowser[User Browser\nhttps://dev.srivenkata.shop]
  VPN_User[Remote User via VPN]
  Bastion_User[Admin via Bastion]

  %% AWS Account
  subgraph AWS_Account["AWS Account"]
    direction LR

    %% Public Subnet
    subgraph Public_Subnet["Public Subnet"]
      direction TB
      Bastion[Bastion Host \n (SSH jumpbox)]
      VPN((VPN Gateway))
      NAT((NAT Gateway))
      FE_ALB[[Frontend ALB\n(HTTPS :443) \n Rule: dev.srivenkata.shop -> frontend-tg]]
      Frontend_TG[[Frontend Target Group \n (frontend instances/containers)]]
    end

    %% Private Subnet (Apps)
    subgraph Private_Subnet["Private Subnet (App Layer)"]
      direction TB
      BE_ALB[[Backend ALB\n(HTTP :80)\nHost rules -> service target groups]]
      subgraph Services["Application Services (AutoScaling / ECS)"]
        direction TB
        Catalogue[catalogue\ncatalogue.backend-dev.srivenkata.shop\nTG: catalogue-tg]
        User[user\nuser.backend-dev.srivenkata.shop\nTG: user-tg]
        Cart[cart\ncart.backend-dev.srivenkata.shop\nTG: cart-tg]
        Shipping[shipping\nshipping.backend-dev.srivenkata.shop\nTG: shipping-tg]
        Payment[payment\npayment.backend-dev.srivenkata.shop\nTG: payment-tg]
      end
    end

    %% Database Subnet
    subgraph DB_Subnet["Database Subnet (Private)"]
      direction TB
      MongoDB(((MongoDB)))
      Redis(((Redis)))
      MySQL(((MySQL)))
      RabbitMQ(((RabbitMQ)))
    end

  end

  %% User traffic flow
  UserBrowser -->|HTTPS 443| FE_ALB
  FE_ALB --> Frontend_TG
  Frontend_TG --> Frontend_App[Frontend App\n(SPA + proxies /api/*)]
  Frontend_App --> BE_ALB

  %% Backend ALB routing
  BE_ALB -->|Host: catalogue.backend-dev.srivenkata.shop| Catalogue
  BE_ALB -->|Host: user.backend-dev.srivenkata.shop| User
  BE_ALB -->|Host: cart.backend-dev.srivenkata.shop| Cart
  BE_ALB -->|Host: shipping.backend-dev.srivenkata.shop| Shipping
  BE_ALB -->|Host: payment.backend-dev.srivenkata.shop| Payment

  %% Service to DB connections
  Catalogue -->|27017| MongoDB
  User -->|27017| MongoDB
  Cart -->|5679| Redis
  User -->|5679| Redis
  Shipping -->|3306| MySQL
  Payment -->|5672| RabbitMQ

  %% Admin access
  VPN_User --> VPN
  VPN -->|Mgmt SSH & DB access| MongoDB
  Bastion_User --> Bastion
  Bastion -->|SSH to App + DB| Catalogue
  Bastion --> Frontend_TG
  Bastion --> MongoDB

  %% Internet egress
  Frontend_App -->|egress| NAT
  Catalogue -->|egress| NAT

  %% Security Group Notes
  classDef sgNote fill:#fff4cc,stroke:#e0a800;
  SG_Notes[/"Security Groups:\n- mongodb_vpn: allow 22,27017 from VPN\n- mongodb_catalogue: allow 27017 from catalogue\n- mongodb_user: allow 27017 from user\n- redis_vpn, redis_user, redis_cart\n- app SGs (catalogue,user,cart,shipping,payment)\n- backend_alb SG\n- frontend_alb SG\n- vpn SG\n- bastion SG"/]:::sgNote
  SG_Notes --> MongoDB
  SG_Notes --> Redis
  SG_Notes --> MySQL
  SG_Notes --> RabbitMQ
  SG_Notes --> Catalogue
  SG_Notes --> BE_ALB
  SG_Notes --> FE_ALB

  %% Styling
  style UserBrowser fill:#e8f4ff,stroke:#2b7cff
  style VPN_User fill:#e8ffe8,stroke:#2bbf2b
  style Bastion_User fill:#ffe8e8,stroke:#ff2b2b

```
