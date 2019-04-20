function api_BrandingConfig()
  ' Gets branding configuration
  ' {
  '  LoginDisclaimer: string
  '  CustomCss: string
  ' }
  resp = APIRequest("Branding/Configuration")
  return getJson(resp)
end function
