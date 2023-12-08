#!/bin/bash

# Аргументы скрипта
ONEC_USERNAME=$1
ONEC_PASSWORD=$2
ONEC_VERSION=$3
DOWNLOADS_PATH=$4
DISTR_FILTER=$5
APP_FILTER="Технологическая платформа *8\.3"

# Преобразование версии для различных целей
ONEC_VERSION_DOTS=$ONEC_VERSION
ONEC_VERSION_UNDERSCORES=${ONEC_VERSION//./_}
ESCAPED_VERSION=$(echo $ONEC_VERSION_DOTS | sed 's/\./\\./g')

# Функция для проверки наличия файлов дистрибутива в локальной директории
check_local_distr() {
  local file_name_srv="deb64_$ONEC_VERSION_UNDERSCORES.tar.gz"
  local file_name_platform="server64_$ONEC_VERSION_UNDERSCORES.tar.gz"

  if [ -f "/distr/$file_name_srv" ]; then
    echo "Найден локальный дистрибутив: $file_name_srv"
    cp "/distr/$file_name_srv" $DOWNLOADS_PATH/
    return 0
  elif [ -f "/distr/$file_name_platform" ]; then
    echo "Найден локальный дистрибутив: $file_name_platform"
    cp "/distr/$file_name_platform" $DOWNLOADS_PATH/
    return 0
  fi

  return 1
}

# Функция для скачивания дистрибутива
download_distr() {
  local distr_filter=$1
  echo "Попытка скачать дистрибутив с фильтром: $distr_filter"
  yard releases -u $ONEC_USERNAME -p $ONEC_PASSWORD get \
    --app-filter "$APP_FILTER" \
    --version-filter $ESCAPED_VERSION \
    --path $DOWNLOADS_PATH \
    --distr-filter "$distr_filter" \
    --download-limit 1
}


# Удаление ненужных файлов
rm -f $DOWNLOADS_PATH/.gitkeep
chmod 777 -R /tmp

# Проверяем, есть ли дистрибутивы локально
if ! check_local_distr; then
  # Если локального дистрибутива нет, пытаемся скачать
  if ! download_distr "$DISTR_FILTER"; then
    echo "Не удалось найти ни одного дистрибутива с указаным фильтром: $DISTR_FILTER"
      exit 1
    fi
  fi
fi

# Распаковка скачанных файлов(Если такие еще есть)
for file in $DOWNLOADS_PATH/*.tar.gz; do
  tar -xzf "$file" -C $DOWNLOADS_PATH
  rm -f "$file"
done