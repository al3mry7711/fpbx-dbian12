FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت المتطلبات الأساسية
RUN apt update && apt upgrade -y && \
    apt install -y sudo curl wget gnupg2 ca-certificates lsb-release \
    net-tools vim git cron apache2 mariadb-server \
    php php-cli php-mysql php-curl php-mbstring php-xml php-zip \
    php-bcmath php-gd php-soap php-intl libapache2-mod-php \
    build-essential autoconf subversion libtool libxml2-dev uuid-dev \
    libjansson-dev libsqlite3-dev libedit-dev nodejs npm

# إنشاء المستخدم asterisk
RUN adduser asterisk --disabled-password --gecos "" || true

# نسخ سكربت التثبيت إلى الحاوية
COPY install-freepbx.sh /install-freepbx.sh
RUN chmod +x /install-freepbx.sh

# تنفيذ السكربت تلقائيًا
CMD ["/install-freepbx.sh", "--wait"]

