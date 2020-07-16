# Authenticate to AWS with MFA

function Request-AwsAuthentication
{
  param(
    [Parameter(Mandatory = $true)]
    $token,

    [Parameter(Mandatory = $false)]
    [switch]
    $connectToECR,

    [Parameter(Mandatory = $false)]
    $accessKey = $env:awsAccessKey,

    [Parameter(Mandatory = $false)]
    $profileName = $env:awsProfileName,

    [Parameter(Mandatory = $false)]
    $region = 'eu-west-1',

    [Parameter(Mandatory = $false)]
    $secretKey = $env:awsSecretKey,

    [Parameter(Mandatory = $false)]
    $serialNumber = $env:awsSerialNumber
  )

  $sts = Get-STSSessionToken `
    -Region $region `
    -AccessKey $accessKey `
    -SecretKey $SecretKey `
    -ProfileName $profileName `
    -SerialNumber $serialNumber `
    -TokenCode $token

  Set-AWSCredentials -AccessKey $sts.AccessKeyId -SecretKey $sts.SecretAccessKey -SessionToken $sts.SessionToken -StoreAs mfa

  Set-AWSCredentials mfa

  if ($connectToECR.IsPresent)
  {
    (Get-ECRLoginCommand `
        -Region $region `
        -ProfileName mfa).Password | `
      docker login `
      --username AWS `
      --password-stdin "884507746758.dkr.ecr.$region.amazonaws.com"
  }
}

Export-ModuleMember -alias * -function *
