require 'spec_helper'
require 'pathname'
require 'r509/io_helpers'

module TestFixtures
    extend R509::IOHelpers

    FIXTURES_PATH = Pathname.new(__FILE__).dirname + "fixtures"

    def self.read_fixture(filename)
        read_data((FIXTURES_PATH + filename).to_s)
    end

    #Trustwave cert for langui.sh
    CERT = read_fixture('cert1.pem')

    #Trustwave root cert
    STCA_CERT = read_fixture('stca.pem')


    TEST_CA_CERT = read_fixture('test_ca.cer')
    TEST_CA_KEY  = read_fixture('test_ca.key')

    TEST_CA_OCSP_CERT = read_fixture('test_ca_ocsp.cer')
    TEST_CA_OCSP_KEY  = read_fixture('test_ca_ocsp.key')

    TEST_CA_SUBROOT_CERT = read_fixture('test_ca_subroot.cer')
    TEST_CA_SUBROOT_KEY  = read_fixture('test_ca_subroot.key')

    TEST_CA_SUBROOT_OCSP_CERT = read_fixture('test_ca_subroot_ocsp.cer')
    TEST_CA_SUBROOT_OCSP_KEY  = read_fixture('test_ca_subroot_ocsp.key')

    SECOND_CA_CERT = read_fixture('second_ca.cer')
    SECOND_CA_KEY  = read_fixture('second_ca.key')

    OCSP_TEST_CERT = read_fixture('ocsptest.r509.local.pem')

    STCA_OCSP_REQUEST  = read_fixture('stca_ocsp_request.der')
    STCA_OCSP_RESPONSE  = read_fixture('stca_ocsp_response.der')

    def self.test_ca_cert
        R509::Cert.new(:cert => TEST_CA_CERT, :key => TEST_CA_KEY)
    end

    def self.test_ca_subroot_cert
        R509::Cert.new(:cert => TEST_CA_SUBROOT_CERT, :key => TEST_CA_SUBROOT_KEY)
    end

    def self.test_ca_server_profile
        R509::Config::CaProfile.new(
              :basic_constraints => "CA:FALSE",
              :key_usage => ["digitalSignature","keyEncipherment"],
              :extended_key_usage => ["serverAuth"],
              :certificate_policies => [
                    [
                        "policyIdentifier=2.16.840.1.12345.1.2.3.4.1",
                        "CPS.1=http://example.com/cps"
                    ]
                ]
        )

    end

    def self.test_ca_server_profile_with_subject_item_policy
        subject_item_policy = R509::Config::SubjectItemPolicy.new(
            "CN" => "required",
            "O" => "optional",
            "ST" => "required",
            "C" => "required",
            "OU" => "optional"
        )
        R509::Config::CaProfile.new(
            :basic_constraints => "CA:FALSE",
            :key_usage => ["digitalSignature","keyEncipherment"],
            :extended_key_usage => ["serverAuth"],
            :certificate_policies => [
                [
                    "policyIdentifier=2.16.840.1.12345.1.2.3.4.1",
                    "CPS.1=http://example.com/cps"
                ]
            ],
            :subject_item_policy => subject_item_policy
        )
    end

    def self.test_ca_subroot_profile
        R509::Config::CaProfile.new(
                  :basic_constraints => "CA:TRUE,pathlen:0",
                  :key_usage => ["keyCertSign","cRLSign"],
                  :extended_key_usage => [],
                  :certificate_policies => nil)
    end

    def self.test_ca_ocspsigner_profile
        R509::Config::CaProfile.new(
                  :basic_constraints => "CA:FALSE",
                  :key_usage => ["digitalSignature"],
                  :extended_key_usage => ["OCSPSigning"],
                  :certificate_policies => nil)
    end

    def self.second_ca_cert
        R509::Cert.new(:cert => SECOND_CA_CERT, :key => SECOND_CA_KEY)
    end

    def self.second_ca_server_profile
        R509::Config::CaProfile.new(
              :basic_constraints => "CA:FALSE",
              :key_usage => ["digitalSignature","keyEncipherment"],
              :extended_key_usage => ["serverAuth"],
              :certificate_policies => [
                    [
                        "policyIdentifier=2.16.840.1.12345.1.2.3.4.1",
                        "CPS.1=http://example.com/cps"
                    ]
                ]
        )

    end

    def self.second_ca_subroot_profile
        R509::Config::CaProfile.new(
                  :basic_constraints => "CA:TRUE,pathlen:0",
                  :key_usage => ["keyCertSign","cRLSign"],
                  :extended_key_usage => [],
                  :certificate_policies => nil)
    end


    # @return [R509::Config::CaConfig]
    def self.test_ca_config
        crl_list_sio = StringIO.new
        crl_list_sio.set_encoding("BINARY") if crl_list_sio.respond_to?(:set_encoding)
        crl_number_sio = StringIO.new
        crl_number_sio.set_encoding("BINARY") if crl_number_sio.respond_to?(:set_encoding)

        opts = {
          :ca_cert => test_ca_cert(),
          :cdp_location => 'URI:http://crl.domain.com/test_ca.crl',
          :ocsp_location => 'URI:http://ocsp.domain.com',
          :ocsp_start_skew_seconds => 3600,
          :ocsp_validity_hours => 48,
          :crl_list_file => crl_list_sio,
          :crl_number_file => crl_number_sio
        }
        ret = R509::Config::CaConfig.new(opts)

        ret.set_profile("server", self.test_ca_server_profile)
        ret.set_profile("subroot", self.test_ca_subroot_profile)
        ret.set_profile("ocspsigner", self.test_ca_ocspsigner_profile)
        ret.set_profile("server_with_subject_item_policy", self.test_ca_server_profile_with_subject_item_policy)

        ret
    end

    # @return [R509::Config::CaConfig]
    def self.test_ca_subroot_config
        crl_list_sio = StringIO.new
        crl_list_sio.set_encoding("BINARY") if crl_list_sio.respond_to?(:set_encoding)
        crl_number_sio = StringIO.new
        crl_number_sio.set_encoding("BINARY") if crl_number_sio.respond_to?(:set_encoding)

        opts = {
          :ca_cert => test_ca_subroot_cert(),
          :cdp_location => 'URI:http://crl.domain.com/test_ca.crl',
          :ocsp_location => 'URI:http://ocsp.domain.com',
          :ocsp_start_skew_seconds => 3600,
          :ocsp_validity_hours => 48,
          :crl_list_file => crl_list_sio,
          :crl_number_file => crl_number_sio
        }
        ret = R509::Config::CaConfig.new(opts)

        ret.set_profile("server", self.test_ca_server_profile)
        ret.set_profile("subroot", self.test_ca_subroot_profile)
        ret.set_profile("ocspsigner", self.test_ca_ocspsigner_profile)
        ret.set_profile("server_with_subject_item_policy", self.test_ca_server_profile_with_subject_item_policy)

        ret
    end

    # @return [R509::Config::CaConfig] secondary config
    def self.second_ca_config
        opts = {
          :ca_cert => second_ca_cert(),
          :cdp_location => 'URI:http://crl.domain.com/test_ca.crl',
          :ocsp_location => 'URI:http://ocsp.domain.com'
        }
        ret = R509::Config::CaConfig.new(opts)

        ret.set_profile("server", self.second_ca_server_profile)
        ret.set_profile("subroot", self.second_ca_subroot_profile)

        ret
    end
end
