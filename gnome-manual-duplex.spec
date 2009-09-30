Name:           gnome-manual-duplex
# List of additional build dependencies
BuildRequires: gtk2-devel
Version:        0.0
Release:        1
License:        GPL v2 or later
Source:         gnome-manual-duplex-%{version}.tar.gz
Group:          Productivity/Other
Summary:        test

BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
test


%prep
%setup -q

%build

# Assume that the package is built by plain 'make' if there's no ./configure.
# This test is there only because the wizard doesn't know much about the
# package, feel free to clean it up
if test -x ./configure; then
    %configure
fi
make

    

%install

make DESTDIR=%buildroot install
