
variable "avi_password" {}
variable "avi_username" {}
variable "avi_old_password" {}

variable "avi_version" {
  default = "21.1.3"
}

variable "subnetworkName" {
  type = list
  default = ["subnet-mgt", "subnet-backend", "subnet-vip"] # keep the mgt at the first position - it used to define the SE network management
}

variable "subnetworkCidr" {
  type = list
  default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}

variable "sgTcp" {
  type = list
  default = ["22", "53", "80", "8080", "443", "3306", "8443"]
}

variable "sgUdp" {
  type = list
  default = ["53"]
}

variable "ssh_key" {
  default = {
    private = "~/creds/ssh/cloudKey"
    public = "~/creds/ssh/cloudKey.pub"
  }
}


variable "jump" {
  type = map
  default = {
    name = "jump"
    type = "e2-medium"
    image = "ubuntu-os-cloud/ubuntu-2004-lts"
    userdata = "userdata/jump-ubuntu_20.sh"
    avisdkVersion = "21.1.3"
    username = "ubuntu"
  }
}

variable "ansible" {
  type = map
  default = {
    version = "2.10.7"
    prefixGroup = "gcp"
    gcpServiceAccount = "/home/nic/creds/gcp/projectavi-283209-298e9656bfa5.json"
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.53"
    aviConfigureTag = "v6.08"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
  }
}

variable "backend" {
  type = map
  default = {
    type = "e2-micro"
    image = "ubuntu-os-cloud/ubuntu-2004-lts"
    userdata = "userdata/backend.sh"
    count = 2
    url_demovip_server = "https://github.com/tacobayle/demovip_server"
    username = "ubuntu"
  }
}

variable "controller" {
  default = {
    name = "avi-controller"
    image_name = "avi-image"
    type = "e2-standard-8"
    diskName = "avi-controller"
    diskType = "pd-ssd"
    diskSize = "128"
    environment = "GCP"
    cluster = false
    count = "1"
    dns =  ["8.8.8.8", "8.8.4.4"]
    ntp = ["95.81.173.155", "188.165.236.162"]
    floating_ip = "1.1.1.1"
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "false"
    tenant_access_to_provider_se = "true"
    tenant_vrf = "false"
    aviCredsJsonFile = "~/.creds.json"
  }
}

variable "gcp" {
  default = {
    dnsZoneName = "avidemo"
    bucket = {
      name = "bucket-avi"
    }
    vpc = {
      name = "vpc-avi"
    }
    project = {
      name = "projectavi-283209"
    }
    email = "terraform@projectavi-283209.iam.gserviceaccount.com"
    region = "europe-north1"
    sgName = "sg-avi"
    name = "cloudGcp"
    firewall_target_tags = "avi-fw-tag"
    domains = [
      {
        name = "gslb.avidemo.fr"
      }
    ]
    network_vip = {
      cidr = "192.168.10.0/24"
      type = "V4"
      ipStartPool = "51"
      ipEndPool = "100"
    }
    serviceEngineGroup = [
      {
        name = "Default-Group"
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs = 2
        buffer_se = 0
        instance_flavor = "e2-standard-2"
        realtime_se_metrics = {
          enabled = true
          duration = 0
        }
      },
      {
        name = "seGroupCpuAutoScale"
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs = 1
        buffer_se = 0
        instance_flavor = "e2-standard-2"
        extra_shared_config_memory = 0
        auto_rebalance = true
        auto_rebalance_interval = 30
        auto_rebalance_criteria = [
          "SE_AUTO_REBALANCE_CPU"
        ]
        realtime_se_metrics = {
          enabled = true
          duration = 0
        }
      },
      {
        name: "seGroupGslb"
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs: 1
        buffer_se: 0
        instance_flavor = "e2-standard-2"
        extra_shared_config_memory = 2000
        realtime_se_metrics = {
          enabled: true
          duration: 0
        }
      }
    ]
    httppolicyset = [
      {
        name = "http-request-policy-app3-content-switching-gcp"
        http_request_policy = {
          rules = [
            {
              name = "Rule 1"
              match = {
                path = {
                  match_criteria = "CONTAINS"
                  match_str = ["hello", "world"]
                }
              }
              rewrite_url_action = {
                path = {
                  type = "URI_PARAM_TYPE_TOKENIZED"
                  tokens = [
                    {
                      type = "URI_TOKEN_TYPE_STRING"
                      str_value = "index.html"
                    }
                  ]
                }
                query = {
                  keep_query = true
                }
              }
              switching_action = {
                action = "HTTP_SWITCHING_SELECT_POOL"
                status_code = "HTTP_LOCAL_RESPONSE_STATUS_CODE_200"
                pool_ref = "/api/pool?name=pool1-hello-gcp"
              }
            },
            {
              name = "Rule 2"
              match = {
                path = {
                  match_criteria = "CONTAINS"
                  match_str = ["avi"]
                }
              }
              rewrite_url_action = {
                path = {
                  type = "URI_PARAM_TYPE_TOKENIZED"
                  tokens = [
                    {
                      type = "URI_TOKEN_TYPE_STRING"
                      str_value = ""
                    }
                  ]
                }
                query = {
                  keep_query = true
                }
              }
              switching_action = {
                action = "HTTP_SWITCHING_SELECT_POOL"
                status_code = "HTTP_LOCAL_RESPONSE_STATUS_CODE_200"
                pool_ref = "/api/pool?name=pool2-avi-gcp"
              }
            },
          ]
        }
      }
    ]
    pools = [
      {
        name = "pool1-hello-gcp"
        lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
      },
      {
        name = "pool2-avi-gcp"
        application_persistence_profile_ref = "System-Persistence-Client-IP"
        default_server_port = 8080
      }
    ]
    virtualservices = {
      http = [
        {
          name = "app1-hello-world-gcp"
          pool_ref = "pool1-hello-gcp"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
        {
          name = "app2-avi-gcp"
          pool_ref = "pool2-avi-gcp"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
        {
          name = "app3-content-switching-gcp"
          pool_ref = "pool2-avi-gcp"
          http_policies = [
            {
              http_policy_set_ref = "/api/httppolicyset?name=http-request-policy-app3-content-switching-gcp"
              index = 11
            }
          ]
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        }
      ]
      dns = [
        {
          name = "app4-dns"
          services: [
            {
              port = 53
            }
          ]
        },
        {
          name = "app5-gslb"
          services: [
            {
              port = 53
            }
          ]
          se_group_ref: "seGroupGslb"
        }
      ]
    }
  }
}