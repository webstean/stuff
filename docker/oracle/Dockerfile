FROM oraclelinux:8-slim as oracleclient

RUN microdnf update && microdnf install -y dnf-utils zip unzip bash && microdnf clean all

ENTRYPOINT ["/bin/sh"]
