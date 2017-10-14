FROM library/nginx:stable
LABEL maintainer="ludovic.desfontaines@gmail.com"

RUN set -x \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y adb \
	&& apt-get autoremove -y --purge \
	&& apt-get clean -y


RUN /bin/mkdir -p /root/.android/ \
	&& chmod 750 /root/.android/
COPY content/androidTvTester.sh /root/androidTvTester.sh

VOLUME /root/.android
EXPOSE 80/tcp
STOPSIGNAL SIGKILL
CMD ["/root/androidTvTester.sh"]
