ARG OPENSEARCH_VERSION=2

FROM opensearchproject/opensearch:${OPENSEARCH_VERSION}

RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-performance-analyzer \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security-analytics \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-reports-scheduler \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-cross-cluster-replication \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-notifications \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-notifications-core \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-alerting \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-anomaly-detection \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-asynchronous-search \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-neural-search \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-knn \
    && /usr/share/opensearch/bin/opensearch-plugin remove opensearch-geospatial \
    && rm -rf /usr/share/opensearch/config/opensearch-security/ \
    && rm -rf /usr/share/opensearch/plugins/opensearch-security