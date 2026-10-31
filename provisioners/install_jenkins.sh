#!/bin/bash
set -e
dnf install -y java-21-amazon-corretto git wget fontconfig
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
dnf install -y jenkins
systemctl enable --now jenkins
