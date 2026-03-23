project_name = "landing-zone"      
env          = "DEV"              
location     = "UK South"

# global allowlists – note the mess:
# - extra spaces
# - duplicate CIDRs
allowed_cidrs_http = [
  "10.0.0.0/24",
  "10.0.0.0/24",     # duplicate
  " 10.0.1.0/24 ",   # whitespace
  "10.0.2.0/24"
]

allowed_cidrs_https = [
  "10.0.1.0/24",
  "10.0.1.0/24",     # duplicate
  " 10.0.3.0/24 "    # whitespace
]

# rule definitions – also messy:
# - allow_group not consistently cased
# - source_cidrs has whitespace
# - names have underscores / different styles
nsg_rules = {
  allow_http_from_office = {
    priority         = 100
    direction        = "Inbound"
    access           = "Allow"
    protocol         = "Tcp"
    destination_port = 80
    source_cidrs     = [" 10.0.10.0/24 "]
    allow_group      = "HTTP"
  }

  Allow-HTTPS-From-Office = {
    priority         = 110
    direction        = "Inbound"
    access           = "Allow"
    protocol         = "Tcp"
    destination_port = 443
    source_cidrs     = ["10.0.10.0/24", "10.0.10.0/24"]  # dupes
    allow_group      = "https"
  }
}

