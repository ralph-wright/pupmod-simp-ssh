require 'spec_helper'

shared_examples_for "an ssh server" do
  it { is_expected.to create_class('ssh::server') }
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('ssh') }

  it { is_expected.to create_file('/var/empty/sshd').with({
      :ensure  => 'directory',
      :require => 'Package[openssh-server]'
    })
  }

  it { is_expected.to create_file('/var/empty/sshd/etc').with({
      :ensure  => 'directory',
      :require => 'Package[openssh-server]'
    })
  }

  it { is_expected.to create_file('/var/empty/sshd/etc/localtime').with({
      :source  => '/etc/localtime',
      :require => 'Package[openssh-server]'
    })
  }

  it { is_expected.to contain_group('sshd') }

  it { is_expected.to contain_package('openssh-server').with_ensure('latest') }
  it { is_expected.to contain_package('openssh-ldap').with_ensure('latest') }

  it { is_expected.to contain_user('sshd').with({
      :ensure    => 'present',
      :allowdupe => false,
      :gid       => '74',
      :uid       => '74'
    })
  }

  it { is_expected.to contain_service('sshd').with({
      :ensure  => 'running',
      :require => 'Package[openssh-server]'
    })
  }
end

describe 'ssh::server' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts
    end

    context "on #{os}" do
      context "with default parameters" do
        it_behaves_like "an ssh server"
        it {
          is_expected.to contain_sshd_config('Ciphers').with_value(
            ['aes256-gcm@openssh.com',
             'aes128-gcm@openssh.com',
             'aes256-cbc',
             'aes192-cbc',
             'aes128-cbc']
        )}
      end

      context "with enable_fallback_ciphers=false" do
        let(:pre_condition){
          "class{'ssh::server::conf': enable_fallback_ciphers => false }"
        }
        it_behaves_like "an ssh server"
        it {
          is_expected.to contain_sshd_config('Ciphers').with_value(
            ['aes256-gcm@openssh.com', 'aes128-gcm@openssh.com']
        )}
      end
    end
  end
end
