# NordCloud Assessment

## The assignment:
1)	Provided Resources
    •	Customer has provided you the GIT repo https://github.com/nordcloud/notejam with
    •	Documentation how to build and run application locally
    •	Application source code
    •	Unit tests for testing the application

2)	Business Requirements
    •	The Application must serve variable amount of traffic. Most users are active during business hours. During big events and conferences the traffic could be 4 times more than typical.
    •	The Customer takes guarantee to preserve your notes up to 3 years and recover it if needed.
    •	The Customer ensures continuity in service in case of datacenter failures.
    •	The Service must be capable of being migrated to any regions supported by the cloud provider in case of emergency.
    •	The Customer is planning to have more than 100 developers to work in this project who want to roll out multiple deployments a day without interruption / downtime.
    •	The Customer wants to provision separated environments to support their development process for development, testing, production in the near future.
    •	The Customer wants to see relevant metrics and logs from the infrastructure for quality assurance and security purposes.

3)	Outputs
    •	The Customer wants you to present your solution and demonstrate the benefits supported by proper documentation.
    •	provide all the source code produced in the creation of the infrastructure in an organized way.

## Solution Design
After considering the customer requirements, I have designed the below solution intent on Azure Cloud. The reasoning of solution is described as follows.

## Application Gateway:

Azure application gateway is a web traffic load balancer that enables to manage traffic on the web applications. In our solution, Application gateway has a frond end IP which is exposed a public endpoint so that users requests can be accessed over internet (HTTPS).

As most of the users are active during business hours and the traffic will be 4 times high that typical during big events, application gateway will be able to autoscale based on the changing traffic load patterns.

Note: Autoscaling feature of application gateway is only supported with Standard_v2 or WAF_v2 SKU.

o	Backend pool:
A new backend pool has been created for App Services with two WebApps.

o	Create HTTPS settings for App Service:
As the incoming traffic to the public endpoint is HTTPS, we want to configure the protocol as HTTPS. Also configured the health probe with the backend aggress.

o	Configure Listener to accept incoming requests:
Listener settings have been configured to HTTPS and tied up with Backend pool and HTTPS settings.

o	Restrict direct access to WebApp:
We need to restrict the users accessing WebApp directly over internet. I have configured the app service IP restriction feature so that WebApps will only listens to the application gateway VIP. 

o	The application gateway is configured for URL based routing so that the test workload will be deployed to test WebApp (WebApp1) and Production workload to WebApp2.
In order to ensure enhanced security of the notejam web application, I have implemented application gateway with Web Application Firewall (WAF). 

## App Service WebApp

Azure App Service is an HTTP-based service for hosting web applications. In our case, I have created two Python web applications which uses a shared Azure App Service Environment (ASE).This will deploy the web application on an isolated and dedicated (compute) environment and also enables auto load balancing for the app requests. It supports the deployment of app service to the specified virtual network.

o	Python WebApp:
A python web app has been created and deployed flask application on that. As the current Notejam application is developed using Python 2.7 version and it is going to be deprecated end of this year, we need to refactor the whole application to support on Python 3.6 or greater. During this assessment, I have used Python 2.7.


I have created 2 WebApps with same features, in that one will be used for test environment and other one for production.

o	WebApp1:
This is the test WebApp instance where developers can test the application efficiently. 

o	WebApp2:
This is the production instance where production workloads will be deployed.

o	Deployment Slots:
Deployment slots are live apps with their own host names. In our solution, as the customer wants to segregate the environments between DTAP, I have created deployment slots for Dev & Test on WebApp 1 and Staging & Production on WebApp 2.

## Azure SQL

Azure SQL Database is a relational database as a service (DBaaS) based on the latest stable version of Microsoft SQL Server Database Engine.

In our solution, there are two Azure SQL servers – one for test environment (SQL1) and one for production workloads (SQL2). The web apps are configured with Azure SQL connection string and SQL servers are configured to “Allow access to Azure services” so that firewall rules are not required to configure.

o	Backup for long-term retention:
As customer has a requirement to preserver the user notes for 3 years, I have configured backup for SQL database. The backup schedule is weekly which in turn store the date to Blob storage.

o	Azure SQL connection strings:
The connection stings are used in WebApp to connect with SQL database for respective environments.

o	Business continuity:
Azure SQL is a PaaS service and it incorporate load balancing and high availability as a built-in feature. Microsoft offers 99.9% of availability with Azure SQL servers.
