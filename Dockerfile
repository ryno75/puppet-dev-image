ARG base_image_name=fedora
ARG base_image_version=26

FROM ${base_image_name}:${base_image_version}

LABEL version="1.0"
LABEL description="A lightweight Puppet development image based off of the \
Fedora Linux docker image."
LABEL maintainer="ryno75@gmail.com"

ENV USER_NAME="Ryan Kennedy"
ENV EMAIL_ADDRESS="rkennedy@2ndwatch.com"
ENV PUPPET_AGENT_VERSION=1.10.4
ENV RUBY_AWS_SDK_VERSION=2.10.9

# install vim, puppet and related libs
#RUN yum install -y --nogpgcheck http://yum.puppetlabs.com/el/6/PC1/x86_64/puppetlabs-release-pc1-1.1.0-5.el6.noarch.rpm
RUN dnf install -y --nogpgcheck http://yum.puppetlabs.com/fedora/f25/PC1/x86_64/puppetlabs-release-pc1-1.1.0-5.fedoraf25.noarch.rpm
RUN dnf install -y gcc gcc-c++ libstdc++-devel zlib-devel redhat-rpm-config vim ruby ruby-devel git bash-completion puppet-agent-${PUPPET_AGENT_VERSION}
RUN /opt/puppetlabs/puppet/bin/gem install aws-sdk --version ${RUBY_AWS_SDK_VERSION}

# install bundler in Puppet gem dir
RUN gem install bundler
RUN bundler config silence_root_warning true

# configure git
RUN git config --global user.name "${USER_NAME}"
RUN git config --global user.email "${EMAIL_ADDRESS}"
RUN git config --global credential.helper "!aws codecommit credential-helper $@"
RUN git config --global credential.UseHttpPath true

# configure system-wide PATH to use puppet bin dir
COPY puppet_path.sh /etc/profile.d/puppet_path.sh

## Configure git bash prompt integration (https://github.com/magicmonty/bash-git-prompt)
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
COPY bash-git-prompt.sh /etc/profile.d/bash-git-prompt.sh

## Optionally install the scrooloose vim env (https://github.com/scrooloose/vimfiles)
## This is how the original kopupdev image was set up
#RUN git clone https://github.com/scrooloose/vimfiles.git ~/.vim
#RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#RUN vim +PluginInstall +qall
#RUN ln -s ~/.vim/vimrc ~/.vimrc

## Configure a more lightweight vim/bash/environment
COPY vimrc /root/.vimrc
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle
# install pathogen
RUN curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
# install vim-puppet integration
RUN git clone git://github.com/voxpupuli/vim-puppet.git ~/.vim/bundle/puppet
# install vim-fugitive git integration
RUN git clone git://github.com/tpope/vim-fugitive.git ~/.vim/bundle/ugitive
RUN vim -u NONE -c "helptags vim-fugitive/doc" -c q
# install vim-ruby integration
RUN git clone https://github.com/vim-ruby/vim-ruby.git ~/.vim/bundle/ruby
# install vim-tabular
RUN git clone git://github.com/godlygeek/tabular.git ~/.vim/bundle/tabular
# install syntastic
RUN git clone https://github.com/vim-syntastic/syntastic.git ~/.vim/bundle/syntastic
# install yankring
RUN git clone https://github.com/vim-scripts/YankRing.vim.git ~/.vim/bundle/yankring
# install Nerdtree
RUN git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree

# prepare work dir
RUN mkdir /work

ENTRYPOINT ["bash"]
