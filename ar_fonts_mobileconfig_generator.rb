require 'plist'
require 'uuidtools'

def default_payload
    default_payload = Hash.new
    default_payload['PayloadType'] = 'Configuration'
    default_payload['PayloadVersion'] = 1
    default_payload['PayloadIdentifier'] = 'com.apple.payload'
    default_payload['PayloadUUID'] = UUIDTools::UUID.random_create().to_s
    default_payload['PayloadDescription'] = ''
    default_payload
end

def general_payload(type, identifier, organization, display_name, description)
    general_payload = default_payload()
    general_payload['PayloadType'] = type if type && type.is_a?(String)
    general_payload['PayloadIdentifier'] = identifier if identifier && identifier.is_a?(String)
    general_payload['PayloadDisplayName'] = display_name if display_name && display_name.is_a?(String)
    general_payload['PayloadDescription'] = description if description && description.is_a?(String)
    general_payload['PayloadOrganization'] = organization if organization && organization.is_a?(String)
    general_payload
end

def configuration_payload(identifier, organization, display_name, description, removal_disallowed, payload_content)
    configuration_payload = general_payload('Configuration', identifier, organization, display_name, description)
    configuration_payload['PayloadScope'] = 'System'
    configuration_payload['PayloadRemovalDisallowed'] = removal_disallowed if !!removal_disallowed == removal_disallowed
    configuration_payload['PayloadContent'] = payload_content if payload_content && payload_content.is_a?(Array)
    configuration_payload
end

def font_payload(identifier, organization, display_name, description, name, font)
    font_payload = general_payload('com.apple.font', identifier, organization, display_name, description)
    font_payload['Name'] = name if name && name.is_a?(String)
    font_payload['Font'] = font if font
    font_payload
end

def init
  Dir["*"].reject{|o| not File.directory?(o)}.each do |directory|
    payload_content = Array.new
    (Dir.entries(directory) - ['.', '..']).each do |font|
      font_name = font.sub('.ttf', '')
      payload_content << font_payload("com.apple.font.#{font_name.gsub(' ', '')}", directory, font_name, nil, font_name, File.open("#{directory}/#{font}", 'r'))
    end
    configuration_payload = configuration_payload("com.apple.font.#{directory.gsub(' ', '')}", directory, directory, nil, false, payload_content)
    Plist::Emit.save_plist(configuration_payload, "#{directory}.mobileconfig")
  end
end

init()
