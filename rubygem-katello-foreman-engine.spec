%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

%global gem_name katello-foreman-engine

%define rubyabi 1.9.1
%global katello_bundlerd_dir /usr/share/katello/bundler.d

Summary: Foreman specific parts of Katello
Name: %{?scl_prefix}rubygem-%{gem_name}
Version: 0.0.3
Release: 1%{?dist}
Group: Development/Libraries
License: GPLv2
URL: http://github.com/Katello/katello-foreman-engine
Source0: http://rubygems.org/downloads/%{gem_name}-%{version}.gem
Requires: katello
Requires: %{?scl_prefix}ruby(abi) >= %{rubyabi}
Requires: %{?scl_prefix}rubygem(foreman_api)
Requires: %{?scl_prefix}rubygems
BuildRequires: %{?scl_prefix}rubygems-devel
BuildRequires: %{?scl_prefix}ruby(abi) >= %{rubyabi}
BuildRequires: %{?scl_prefix}rubygems
BuildArch: noarch
Provides: %{?scl_prefix}rubygem(%{gem_name}) = %{version}

%description
Foreman specific parts of Katello.

%package doc
BuildArch:  noarch
Requires:   %{?scl_prefix}%{pkg_name} = %{version}-%{release}
Summary:    Documentation for rubygem-%{gem_name}

%description doc
This package contains documentation for rubygem-%{gem_name}.

%prep
%setup -n %{pkg_name}-%{version} -q -c -T
mkdir -p .%{gem_dir}
%{?scl:scl enable %{scl} "}
gem install --local --install-dir .%{gem_dir} \
            --force %{SOURCE0} --no-rdoc --no-ri
%{?scl:"}

%build

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{katello_bundlerd_dir}
cat <<GEMFILE > %{buildroot}%{katello_bundlerd_dir}/foreman.rb
gem 'katello-foreman-engine'
GEMFILE


%files
%dir %{gem_instdir}
%{gem_instdir}/lib
%{gem_instdir}/script
%exclude %{gem_cache}
%{gem_spec}
%{katello_bundlerd_dir}/foreman.rb
%doc %{gem_instdir}/LICENSE

%exclude %{gem_instdir}/.gitignore
%exclude %{gem_instdir}/test
#%exclude %{gem_instdir}/.travis.yml
%exclude %{gem_dir}/cache/%{gem_name}-%{version}.gem

%files doc
%doc %{gem_instdir}/LICENSE
#%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile
%{gem_instdir}/Gemfile
%{gem_instdir}/%{gem_name}.gemspec

%changelog
* Thu May 30 2013 Ivan Necas <inecas@redhat.com> 0.0.3-1
- Katello admins are admins in foreman too (mhulan@redhat.com)

* Fri May 17 2013 Ivan Necas <inecas@redhat.com> 0.0.2-1
- Installation media integration (inecas@redhat.com)

* Wed May 08 2013 Ivan Necas <inecas@redhat.com> 0.0.1-1
- new package built with tito




