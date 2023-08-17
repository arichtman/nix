{
	"subject": {
    "country": {{ toJson .Insecure.User.country }},
    "organization": {{ toJson .Insecure.User.organization }},
    "organizationalUnit": {{ toJson .Insecure.User.organizationalUnit }},
    "commonName": {{toJson .Subject.CommonName }}
	},
	"keyUsage": ["certSign", "crlSign"],
	"basicConstraints": {
		"isCA": true,
		"maxPathLen": 0
	}
}
