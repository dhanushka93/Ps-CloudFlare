<#

.NOTES
    Author:LooneDAW (Dhanushka93)
    Email: 

.DESCRIPTION
    This Powershell script used retrive DNS information from CloudFlare and 
    export the result to a CSV.


#>


# URL for Verfying Cloudflare API token
$URL_VERIFY_TOKEN = "https://api.cloudflare.com/client/v4/user/tokens/verify"



#URL for Zones
$URL_ZONE = "https://api.cloudflare.com/client/v4/zones?match=all"


$HEADERS = @{
    'Authorization' = 'Bearer <Enter your CloudFlare Api Key here>'
    'Content-Type' = 'application/json'
}

$ZONE_RESPONSE = Invoke-RestMethod -Uri $URL_ZONE -Method Get -Headers $HEADERS

#UPDATE BELOW TWO VARIABLES CAREFULLY!!

$ip_address = ""
$CNAME = ""


foreach ($zone in $ZONE_RESPONSE.result.id)
{
    $URL_GET_DNS = "https://api.cloudflare.com/client/v4/zones/$zone/dns_records?type=A&content=$ip_address&match=all"

    $DNS_RESPONSE = Invoke-RestMethod -Uri $URL_GET_DNS -Method Get -Headers $HEADERS 
	
	$UPDATE_DNS_URL = "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/"
	
	
#To Replace with the {Snippet 1.0}
	foreach ($record in $DNS_RESPONSE.result)
	{
		$record_rep = [string]$record.name
		
		$subdomain = $record_rep.Replace("."+[string]$record.zone_name, "")
		
		$NEW_URL = $UPDATE_DNS_URL + [string]$record.id
		
		Invoke-RestMethod -Uri $NEW_URL -Method Delete -Headers $HEADERS
		
		$BODY = @{
			"type"="CNAME"
			"name"=$subdomain
			"content"=$CNAME
			"ttl"=1
			"proxied"= $false
			} | ConvertTo-Json

		$CREATE_DNS = Invoke-RestMethod -Uri $UPDATE_DNS_URL -Method Post -Headers $HEADERS -Body $BODY

		
	}
  # Snippet 1.0 : Use following section to produce list of DNS records to a CSV
  
    <# foreach ($record in $DNS_RESPONSE.result)
    {

        $hash_table = @{

            "IP Adress" = "$record.content"
            "Domain" = "$record.name"
        }
        $dns_rec = $hash_table
       #$record | Select-Object @{n="IP Address";e={$record.content}} , @{n="Subdomain";e={$record.name}} | Export-Csv -Path ".\result_ $ip_address.csv" -Append -Force
    } #>
   

    
    

    

}


