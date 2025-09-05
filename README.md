# roboshop-infra-dev
```mermaid

flowchart LR
  %% 🌐 External Users
  UserBrowser["🧑‍💻 **User Browser**<br>🔗 https://dev.srivenkata.shop"]
  VPN_User["🛡️ **Remote User via VPN**"]
  Bastion_User["🔑 **Admin via Bastion**"]

  %% ☁️ AWS Account
  subgraph AWS_Account["☁️ **AWS Account**"]
    direction LR

    %% 🌎 Public Subnet
    subgraph Public_Subnet["🌎 **Public Subnet**"]
      direction TB
      Bastion["🟩 **Bastion Host**<br>(SSH jumpbox)"]
      VPN["🔒 **VPN Gateway**"]
      NAT["🌐 **NAT Gateway**"]
      FE_ALB["🚦 **Frontend ALB**<br>(HTTPS :443)<br>Rule: dev.srivenkata.shop ➡️ frontend-tg"]
      Frontend_TG["🎯 **Frontend Target Group**<br>(frontend instances/containers)"]
    end

    %% 🔒 Private Subnet (Apps)
    subgraph Private_Subnet["🔒 **Private Subnet (App Layer)**"]
      direction TB
      BE_ALB["🚦 **Backend ALB**<br>(HTTP :80)<br>Host rules ➡️ service target groups"]
      subgraph Services["🛠️ **Application Services (AutoScaling / ECS)**"]
        direction TB
        Catalogue["📦 **catalogue**<br>catalogue.backend-dev.srivenkata.shop<br>TG: catalogue-tg"]
        User["👤 **user**<br>user.backend-dev.srivenkata.shop<br>TG: user-tg"]
        Cart["🛒 **cart**<br>cart.backend-dev.srivenkata.shop<br>TG: cart-tg"]
        Shipping["🚚 **shipping**<br>shipping.backend-dev.srivenkata.shop<br>TG: shipping-tg"]
        Payment["💳 **payment**<br>payment.backend-dev.srivenkata.shop<br>TG: payment-tg"]
      end
    end

    %% 🗄️ Database Subnet
    subgraph DB_Subnet["🗄️ **Database Subnet (Private)**"]
      direction TB
      MongoDB["🍃 **MongoDB**"]
      Redis["🧠 **Redis**"]
      MySQL["🐬 **MySQL**"]
      RabbitMQ["🐇 **RabbitMQ**"]
    end

  end

  %% 🔁 User traffic flow
  UserBrowser -->|🔒 HTTPS 443| FE_ALB
  FE_ALB --> Frontend_TG
  Frontend_TG --> Frontend_App["🌐 **Frontend App**<br>(SPA + proxies /api/*)"]
  Frontend_App --> BE_ALB

  %% 🛣️ Backend ALB routing
  BE_ALB -->|🗂️ Host: catalogue.backend-dev.srivenkata.shop| Catalogue
  BE_ALB -->|🗂️ Host: user.backend-dev.srivenkata.shop| User
  BE_ALB -->|🗂️ Host: cart.backend-dev.srivenkata.shop| Cart
  BE_ALB -->|🗂️ Host: shipping.backend-dev.srivenkata.shop| Shipping
  BE_ALB -->|🗂️ Host: payment.backend-dev.srivenkata.shop| Payment

  %% 🔗 Service to DB connections
  Catalogue -->|🔌 27017| MongoDB
  User -->|🔌 27017| MongoDB
  Cart -->|🔌 5679| Redis
  User -->|🔌 5679| Redis
  Shipping -->|🔌 3306| MySQL
  Payment -->|🔌 5672| RabbitMQ

  %% 🛡️ Admin access
  VPN_User --> VPN
  VPN -->|🔑 **Mgmt SSH & DB access**| MongoDB
  Bastion_User --> Bastion
  Bastion -->|🔑 **SSH to App + DB**| Catalogue
  Bastion --> Frontend_TG
  Bastion --> MongoDB

  %% 🌍 Internet egress
  Frontend_App -->|🌐 egress| NAT
  Catalogue -->|🌐 egress| NAT

  %% 🛡️ Security Group Notes
  SG_Notes["🛡️ **Security Groups**:<br>🍃 **mongodb_vpn**: allow 22,27017 from VPN<br>📦 **mongodb_catalogue**: allow 27017 from catalogue<br>👤 **mongodb_user**: allow 27017 from user<br>🧠 **redis_vpn, redis_user, redis_cart**<br>🛠️ **app SGs** (catalogue,user,cart,shipping,payment)<br>🚦 **backend_alb SG**<br>🚦 **frontend_alb SG**<br>🔒 **vpn SG**<br>🟩 **bastion SG**"]
  SG_Notes --> MongoDB
  SG_Notes --> Redis
  SG_Notes --> MySQL
  SG_Notes --> RabbitMQ
  SG_Notes --> Catalogue
  SG_Notes --> BE_ALB
  SG_Notes --> FE_ALB

  %% -----------------------
  %% Per-node styling (high-contrast, highlighted strokes)
  %% -----------------------

  %% External users - bright, readable
  style UserBrowser fill:#e0f4ff,stroke:#0066cc,stroke-width:4px,color:#02294a
  style VPN_User fill:#e8fff0,stroke:#008a45,stroke-width:4px,color:#02331f
  style Bastion_User fill:#fff0f0,stroke:#cc0033,stroke-width:4px,color:#3d0a0a

  %% Subnets - vivid pastels with stronger borders for hierarchy
  style Public_Subnet fill:#dff7f4,stroke:#00a686,stroke-width:5px,color:#03332f
  style Private_Subnet fill:#ffece6,stroke:#ff6f3c,stroke-width:5px,color:#4a1c10
  style DB_Subnet fill:#fff7e6,stroke:#e69a00,stroke-width:5px,color:#3d2a00

  %% ALBs and target group - clear blue / coral contrast
  style FE_ALB fill:#cfe9ff,stroke:#0073e6,stroke-width:3px,color:#032d60
  style BE_ALB fill:#ffd9d9,stroke:#cc1f1f,stroke-width:3px,color:#4a1212
  style Frontend_TG fill:#cfe9ff,stroke:#0073e6,stroke-width:3px,color:#032d60

  %% Frontend App - highlighted container so /api/* proxies are obvious
  style Frontend_App fill:#dfeaff,stroke:#235bd1,stroke-width:4px,color:#041f4a

  %% Application services - each distinct, high-contrast text
  style Catalogue fill:#00c9b1,stroke:#007a63,stroke-width:3px,color:#04221f
  style User fill:#4fc3ff,stroke:#007fb3,stroke-width:3px,color:#03263a
  style Cart fill:#ff9f4f,stroke:#b34900,stroke-width:3px,color:#3d1a00
  style Shipping fill:#ffd24f,stroke:#b37a00,stroke-width:3px,color:#442f00
  style Payment fill:#ff88cc,stroke:#b3005a,stroke-width:3px,color:#3b0f2b

  %% Databases - greens/teals with dark labels
  style MongoDB fill:#d6ffee,stroke:#00a862,stroke-width:3px,color:#062b21
  style Redis fill:#e6fff9,stroke:#00a686,stroke-width:3px,color:#07332b
  style MySQL fill:#dff0ff,stroke:#0077b3,stroke-width:3px,color:#042a44
  style RabbitMQ fill:#ffe8d6,stroke:#cc6a00,stroke-width:3px,color:#3c2608

  %% Networking components - NAT & VPN highlighted
  style NAT fill:#fff0d9,stroke:#ff9500,stroke-width:4px,color:#3d2a06
  style VPN fill:#eaf9ee,stroke:#00b067,stroke-width:4px,color:#07321d

  %% Bastion - prominent so admin access stands out
  style Bastion fill:#e8fff0,stroke:#007a2e,stroke-width:5px,color:#02321a

  %% Security Group notes - warm background + dark text
  style SG_Notes fill:#fff1d6,stroke:#c77400,stroke-width:4px,color:#2e1b00

  %% Helper: make route labels readable (line text)
  linkStyle default fill:none,stroke:#666,stroke-width:1.5px,color:#222
```






















