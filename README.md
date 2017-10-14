<H1>androidTvTester</H1>
Allows its user to test if an AndroidTV is up or down.

<H1>How to use it</H1>
Works by instanciating a new docker container.
You can get the latest image from Dockerhub by just typing docker pull geekcitizen/androidTvTest:x86_latest

<H1>Limitations</H1>
Please note that this container does actually not run on anything else than x86 hosts. Indeed, it relies on adb (look at Dockerfile).
