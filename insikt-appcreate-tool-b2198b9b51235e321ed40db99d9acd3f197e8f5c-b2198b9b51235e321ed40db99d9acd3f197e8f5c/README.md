The scripts allow app creation, through disbursement, for retail & online tenants, across multiple environments.
Scope of the script can be limited on the fly to create an app in any desired app state/step.
The request inputs can be manipulated by simply updating the appropriate payload(s) before executing the script.
All the request-responses are output to stdout.

### Scope

* The script supports app creation through disbursement/funding and all app states/steps in between.
* It supports manipulation of app inputs, but for certain calls only (listed below). Additional calls will be supported if deemed useful.
* Supports multiple environments - qa, training, dev(docker)
* Supports online & retail tenants.
* Tenant agent is looked up and(or) created as part of the script.

## Getting Started ##

### Prerequisites ###

* Jmeter must be installed on your local machine. Current stable ver, as of Nov 29 2017, is v3.2.

On mac: **brew install Jmeter**

To verify installation: In terminal, type 'jmeter' and hit enter. This should launch Jmeter (GUI) instance.
_**Note**: We'd be using the Non-GUI CLI for script execution._
* Add postgres jdbc driver dependency :-

    * Go to https://jdbc.postgresql.org/download.html
    * Download driver jar 42.2.0 (latest as of 1/22/18) 
    * Put the downloaded jar under jmeter installation: `/usr/local/Cellar/jmeter/3.2/libexec/lib/`
    
* Clone git project **insikt-appcreate-tool**
* If input/payload for a request needs to be modified, make sure you update the applicable request's payload file(s) under _`/files`_ dir before running the script. Request payloads that can currently be modified:-
    * Submit prequal: preQualStart.json & preQualStart_listo.json(for listo)
    * Submit preapproval: preApprovalStart.json
    * Submit preferred loan (post preapproval): preApprovalStart_prefLoan.json
* The _`/defaultFiles_backup`_ dir has the default, unmodified payloads.**Note**: Never modify the payloads in _`/defaultFiles_backup`_ dir.

**!!! Important !!!** : If you update a payload file under _`/files`_ dir, it will be permanent and will be used for subsequent script runs. If you need to revert any changes in the future, copy the affected payload(s) files from the _`/defaultFiles_backup`_ dir into _`/files`_ dir. The _`/defaultFiles_backup`_ dir has the default, unmodified payloads.


## Executing the script ##

**note**: As of 1/18/18 there is an issue with the script completing retail disbursement step. Please manually complete disbursement step on webapp until then.

1. Git pull remote master for latest updates/fixes.
2. Go to the local git repo dir `insikt-appcreate-tool/jmeterScripts/`
**Note**: the script must be run from this location.
3. If _online_ tenant, you'll be using script **onlineAppCreate.jmx**. If _retail_ tenant, you'll be using **retailAppCreate.jmx**.
4. If required, modify payload(s) under _`/files`_ dir . 
**Note**: refer to !!!Important!!! disclaimer above.
5. Run the command:-

    If **retail** tenant: `jmeter -n -t retailAppCreate.jmx -Jenv=qa -Jtenant=102 -Jscope=finalApproval -l logs.txt`
    
    If **online** tenant: `jmeter -n -t onlineAppCreate.jmx -Jenv=qa -Jtenant=128  -Jscope=submitFinancialInfo -l logs.txt`
    
    _**Note**: Passing parameters to the script is optional. If not passed, the _default_ values mentioned below will be used._
    
    
6. The script will output APP ID, PARTY ID, PRODUCT KEY when available. Also, all the requests-responses will be output to stdout(to help in debugging). A log file, with more info, is generated if the ''-l  <logfilename>' argument is passed like above.

## Script parameters ##

First and foremost, like called out above, you can modify app inputs by modifying the payload file(s) under _`/files`_ dir as needed. The script will pick up those json files.


##### Parameter name= **env** #####

description: The environment the script will be run against. (Note: Make sure all the required apps are deployed and running in the env).

default: qa

_ex: -Jenv=me_

| Value    | Description                     |
|----------|---------------------------------|
| qa       | QA environment.                 |
| training | Training env                    |
| dev      | DEV env (pointing to docker db) |
| me       | For local env you must use 'me' |

##### Parameter name= **tenant**
description: The tenant ID.

default- 101 i.e. dolex for retail & 128 i.e. netspend for online.

_ex: -Jtenant=101_

##### Parameter name= **scope**
description: Sets the scope of the script execution which defines the final state/step of the desired app. **Note**: the values are different for online vs. retail.

default: full

_ex: -Jscope=full_

For **_retail_** (i.e. when running retailAppCreate.jmx)

| Value         | Description                                                                                 |
|---------------|---------------------------------------------------------------------------------------------|
| full          | Will create an app through disbursement complete. This is the _default_ scope for script.   |
| start         | Will start a new app and stop at prequal start                                              |
| preQual       | Will create an app through pre-qualification complete                                       |
| preApproval   | Will create an app through pre-approval complete                                            |
| docUpload     | Will create an app through document uploads(doc upload v1)                                  |
| finalApproval | Will create an app through final-approval complete. Will also run doc review(doc review v1) |
| notification  | Will create an app through notification complete.                                           |


For **_online_** (i.e. when running onlineAappCreate.jmx)

| Value               | Description                                                                                       |
|---------------------|---------------------------------------------------------------------------------------------------|
| full                | Will create an app through funding complete. This is the _default_ scope for script.              |
| createAccount       | Will create a new applicant account. Note: App not started                                        |
| submitPersonalInfo  | Will perform 'submit personal info' step, which also completes pre-screen(for ntsp)               |
| submitFinancialInfo | Will perform 'submit financial info' step, which also completes final-approval(for ntsp)          |
| selectLoan          | Will perform 'choose loan' step after approved final-approval, which also completes notification. |
| signLoanContract    | Will perform 'sign loan contract' step, which also completes disbursement (but not funding).      |

##### Parameter name= **campaign**
description: The Campaign ID for the tenant. Only applicable for _online_.

default: The script will use the latest campaign for tenant in DB i.e. campaign with max(start_date).
**Note**: Always make sure valid and unused solicitation exists for the campaign. The script doesn't create new solicitations.

_ex: -Jcampaign=102_


##### Parameter name= **adminUname** & **adminPwd**
description: Admin user credentials. Used in _retail_ script for doc review steps.

default: root@insikt.com creds.

_ex: -JadminUname=admin@dolex.com  -JadminPwd=password_

##### _Future iterations scope_ #####

* _Currently any request payload which relies on dynamic values like specific dates, solicitation key etc. is not modifiable via input files. Explore mechanisms to support them._
* _Use Doc Upload v2 and Doc Review v2 endpoints instead of v1._
* _Most retail tenant appflow variations are supported, but not all._
* _Create prospect and solicitation keys as part of the script if a usable one doesn't exist for campaign._
* _Add GPO Online appflow variations when code ready for QA._