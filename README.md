flowchart LR
  %% External Users
  U["🧑‍💻 **User Browser**<br/>🔗 https://dev.srivenkata.shop"]
  V["🛡️ **Remote User via VPN**"]
  BUser["🔑 **Admin via Bastion**"]

  %% AWS Account
  subgraph AWS["☁️ **AWS Account**"]
    direction LR

    %% Public Subnet
    subgraph Public["🌎 **Public Subnet**"]
      direction TB
      Bastion["🟩 **Bastion Host**<br/>(SSH jumpbox)"]
      VPNGW["🔒 **VPN Gateway**"]
      NATG["🌐 **NAT Gateway**"]
      FEALB["🚦 **Frontend ALB**<br/>(**HTTPS :443**)"]
      FETG["🎯 **Frontend Target Group**<br/>(frontend instances / containers)"]
    end

    %% Private Subnet (Apps)
    subgraph Private["🔒 **Private Subnet (App Layer)**"]
      direction TB
      BEALB["🚦 **Backend ALB**<br/>(**HTTP :80**)"]
      subgraph Apps["🛠️ **Application Services (AutoScaling / ECS)**"]
        direction TB
        Catalogue["📦 **catalogue**<br/>catalogue.backend-dev.srivenkata.shop<br/>TG: catalogue-tg"]
        UserSvc["👤 **user**<br/>user.backend-dev.srivenkata.shop<br/>TG: user-tg"]
        Cart["🛒 **cart**<br/>cart.backend-dev.srivenkata.shop<br/>TG: cart-tg"]
        Shipping["🚚 **shipping**<br/>shipping.backend-dev.srivenkata.shop<br/>TG: shipping-tg"]
        Payment["💳 **payment**<br/>payment.backend-dev.srivenkata.shop<br/>TG: payment-tg"]
      end
    end

    %% Database Subnet
    subgraph DB["🗄️ **Database Subnet (Private)**"]
      direction TB
      MongoDB["🍃 **MongoDB**"]
      Redis["🧠 **Redis**"]
      MySQL["🐬 **MySQL**"]
      RabbitMQ["🐇 **RabbitMQ**"]
    end
  end

  %% Frontend App (explicit block so it's highlighted)
  FrontendApp["🌐 **Frontend App**<br/>(**SPA + proxies /api/***)"]

  %% Host rules highlighted box
  HostRules["🗂️ **Host routing (backend ALB)**<br/>• catalogue.backend-dev.srivenkata.shop<br/>• user.backend-dev.srivenkata.shop<br/>• cart.backend-dev.srivenkata.shop<br/>• shipping.backend-dev.srivenkata.shop<br/>• payment.backend-dev.srivenkata.shop"]

  %% Connections / flows
  U -->|🔒 **HTTPS 443**| FEALB
  FEALB --> FETG
  FETG --> FrontendApp
  FrontendApp -->|🔐 proxied API calls| BEALB

  %% Backend ALB routing to services (host-based)
  BEALB -->|🗂️ catalogue.host| Catalogue
  BEALB -->|🗂️ user.host| UserSvc
  BEALB -->|🗂️ cart.host| Cart
  BEALB -->|🗂️ shipping.host| Shipping
  BEALB -->|🗂️ payment.host| Payment

  %% DB connections (ports shown)
  Catalogue -->|🔌 **27017**| MongoDB
  UserSvc -->|🔌 **27017**| MongoDB
  Cart -->|🔌 **5679**| Redis
  UserSvc -->|🔌 **5679**| Redis
  Shipping -->|🔌 **3306**| MySQL
  Payment -->|🔌 **5672**| RabbitMQ

  %% Admin / VPN / Bastion
  V --> VPNGW
  VPNGW -->|🔑 **Mgmt SSH & DB access**| MongoDB
  BUser --> Bastion
  Bastion -->|🔑 **SSH to App + DB**| Catalogue
  Bastion --> FETG
  Bastion --> MongoDB

  %% Egress
  FrontendApp -->|🌐 **egress**| NATG
  Catalogue -->|🌐 **egress**| NATG

  %% Security Group notes (compact)
  SG["🛡️ **Security Groups**:<br/>• mongodb_vpn: allow 22,27017 from VPN<br/>• mongodb_catalogue: allow 27017 from catalogue<br/>• mongodb_user: allow 27017 from user<br/>• redis_vpn/user/cart<br/>• app SGs (catalogue,user,cart,shipping,payment)<br/>• backend_alb SG / frontend_alb SG / vpn SG / bastion SG"]

  SG --> MongoDB
  SG --> Redis
  SG --> MySQL
  SG --> RabbitMQ
  SG --> Catalogue
  SG --> BEALB
  SG --> FEALB

  %% Styling classes (vibrant, high-contrast)
  class U,V,BUser,Bastion,VPNGW,NATG,FEALB,FETG,BEALB,FrontendApp,HostRules,Apps,DB,Public,Private,SG Catalogue,UserSvc,Cart,Shipping,Payment,MongoDB,Redis,MySQL,RabbitMQ highlight;

  %% Distinct node classes for apps and DBs
  class Catalogue,UserSvc,Cart,Shipping,Payment appnode;
  class MongoDB,Redis,MySQL,RabbitMQ dbnode;
  class Public,Private,DB subnode;
  class HostRules highlightbox;

  %% Definitions (customize once here)
  classDef highlight fill:#fff2cc,stroke:#cc7a00,stroke-width:4px,color:#222,stroke-dasharray: 6 3;
  classDef appnode fill:#66d9cc,stroke:#007a6b,stroke-width:2px,color:#07111a,font-weight:700;
  classDef dbnode fill:#b3ffcc,stroke:#007a33,stroke-width:2px,color:#07111a,font-weight:700;
  classDef subnode fill:#ffe6f0,stroke:#c42b7f,stroke-width:4px,color:#111;
  classDef highlightbox fill:#fff4e6,stroke:#b35600,stroke-width:3px,color:#111,font-weight:800;
  classDef highlight fill:#e6f7ff,stroke:#0066cc,stroke-width:3px,color:#07111a,font-weight:800;

  %% Additional per-node style tweaks (fine tuning)
  style U fill:#cce6ff,stroke:#004aad,stroke-width:3px,color:#07111a
  style V fill:#ccffd9,stroke:#008f39,stroke-width:3px,color:#07111a
  style BUser fill:#ffd9e6,stroke:#c4005a,stroke-width:3px,color:#07111a

  style Public fill:#dff7f0,stroke:#008060,stroke-width:4px,color:#07111a
  style Private fill:#ffe6d9,stroke:#b34d00,stroke-width:4px,color:#07111a
  style DB fill:#fff7cc,stroke:#c48f00,stroke-width:4px,color:#07111a

  style FEALB fill:#99ccff,stroke:#0040b3,stroke-width:3px,color:#07111a
  style BEALB fill:#ffb3b3,stroke:#b30000,stroke-width:3px,color:#07111a
  style FETG fill:#cfe6ff,stroke:#004080,stroke-width:2px,color:#07111a

  style FrontendApp fill:#e6f0ff,stroke:#004aad,stroke-width:3px,color:#07111a
  style HostRules fill:#fffaf0,stroke:#b36b00,stroke-width:3px,color:#07111a

  style SG fill:#fff0d9,stroke:#cc7a00,stroke-width:3px,color:#2a1800
  style Bastion fill:#dfffe6,stroke:#008f39,stroke-width:2px,color:#07111a
  style VPNGW fill:#dfffe6,stroke:#008f39,stroke-width:2px,color:#07111a
  style NATG fill:#f0e6ff,stroke:#5a00b3,stroke-width:2px,color:#07111a

  style Catalogue fill:#66d9cc,stroke:#008080,stroke-width:2px,color:#07111a
  style UserSvc fill:#66c2ff,stroke:#0059b3,stroke-width:2px,color:#07111a
  style Cart fill:#ffb366,stroke:#cc5200,stroke-width:2px,color:#07111a
  style Shipping fill:#ffd966,stroke:#b38600,stroke-width:2px,color:#07111a
  style Payment fill:#ff99cc,stroke:#b30059,stroke-width:2px,color:#07111a

  style MongoDB fill:#b3ffcc,stroke:#008f39,stroke-width:2px,color:#07111a
  style Redis fill:#b3ffe6,stroke:#00997a,stroke-width:2px,color:#07111a
  style MySQL fill:#b3f0ff,stroke:#006699,stroke-width:2px,color:#07111a
  style RabbitMQ fill:#ffdfb3,stroke:#b36b00,stroke-width:2px,color:#07111a
