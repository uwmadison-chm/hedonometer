server "celliwig", user: "sms-sampler", roles: %w{app db web}

set :puma_bind, %w(tcp://127.0.0.1:8006)
