import tensorflow
import numpy as np
import pandas as pd 
from keras.preprocessing.image import ImageDataGenerator, load_img
from tensorflow.keras.utils import to_categorical
from sklearn.model_selection import train_test_split
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Dropout, Flatten, Dense, Activation, BatchNormalization
import matplotlib.pyplot as plt
from keras.models import load_model
from tensorflow.keras.models import Sequential

import random
import os
import asyncio
import shutil

import pathlib
from pathlib import Path

async def nn(path: str):
    #Надо давать путь на папку с папкой внутри которой лежат картинки
    # Типо folder>folder1>image
    # Путь надо надо давать до folder и там должна быть лишь 1 папка - обязательно называться folder1!!!!
    # Внутри folder1 может быть несколько картинок, выдам ответы на все
    dir_path = pathlib.Path.cwd()
    model_path = Path(dir_path, 'nn', 'model.h5')

    model = load_model(model_path)
    FAST_RUN = False
    IMAGE_WIDTH=128
    IMAGE_HEIGHT=128
    batch_size=5
    IMAGE_SIZE=(IMAGE_WIDTH, IMAGE_HEIGHT)
    IMAGE_CHANNELS=3
    test_filenames = os.listdir(path)
    test_df = pd.DataFrame({
        'filename': test_filenames
    })
    
    nb_samples = test_df.shape[0]
    test_gen = ImageDataGenerator(rescale=1./255)
    test_generator = test_gen.flow_from_dataframe(
        test_df, 
        path, 
        x_col='filename',
        y_col=None,
        class_mode=None,
        target_size=IMAGE_SIZE,
        batch_size=batch_size,
        shuffle=False
    )   
    
    predict = model.predict_generator(test_generator, steps=np.ceil(nb_samples/batch_size))
    test_df['category'] = np.argmax(predict, axis=-1)
    sample_test = test_df.head(18)
    sample_test.head()
    
    plt.figure(figsize=(12, 24))
    for index, row in sample_test.iterrows():
        filename = row['filename']
        category = row['category']
        
        img = load_img(Path(path, filename), target_size=IMAGE_SIZE)
        
        plt.subplot(6, 3, int(str(index))+1)
        plt.imshow(img)
        plt.xlabel(str(filename) + '(' + "{}".format(category) + ')' )

    return str(predict[0])
    

async def retraining(path: str):
    """filename: Путь до изображения для дообучения"""

    FAST_RUN = False
    IMAGE_WIDTH = 128
    IMAGE_HEIGHT = 128
    IMAGE_SIZE = (IMAGE_WIDTH, IMAGE_HEIGHT)
    IMAGE_CHANNELS = 3

    dir_path = pathlib.Path.cwd()
    model_path = Path(dir_path, 'nn', 'model.h5')

    model = load_model(model_path)
    filenames = os.listdir(path)
    print(filenames)
    names=[]
    categories = []
    r_name=[]
    i=0

    trans={'ì¿¬«½∞ß¬á∩ π½¿µá':'Никольская улица','î«ß¬«óß¬¿⌐ îÑΓα«»«½¿ΓÑ¡':'Московский Метрополитен','èαáß¡á∩ »½«Θáñ∞':'Красная площадь','ü«½∞Φ«⌐ ΓÑáΓα':'Большой театр','æ¼«Γα«óá∩ »½«Θáñ¬á Panorama360':'Смотровая площадка Panorama360','æ«í«α éáß¿½¿∩ ü½áªÑ¡¡«ú«':'Собор Василия Блаженного',
           'ö«¡Γá¡ äαπªíá ¡áα«ñ«ó':'Фонтан Дружба народов','ä«¡ß¬«⌐ ¼«¡áßΓδα∞':'Донской монастырь','èαπΓ¿µ¬«Ñ »«ñó«α∞Ñ':'Крутицкое подворье','éδßΓáó¬á ñ«ßΓ¿ªÑ¡¿⌐ ¡áα«ñ¡«ú« σ«º∩⌐ßΓóá (éäìò)':'Выставка достижений народного хозяйства (ВДНХ)','òαá¼ òα¿ßΓá æ»áß¿ΓÑ½∩':'Храм Христа Спасителя','î«ß¬«óß¬¿⌐ ú«ßπñáαßΓóÑ¡¡δ⌐ π¡¿óÑαß¿ΓÑΓ ¿¼Ñ¡¿\xa0î.é.ï«¼«¡«ß«óá':'Московский государственный университет имени М.В.Ломоносова',
           'æΓáñ¿«¡ ïπª¡¿¬¿':'Стадион Лужники','æ«í«α¡á∩ »½«Θáñ∞':'Соборная площадь'}

    for doc in filenames:
        d = os.listdir(path+doc)
        for filename in d:
            name = filename.split('.')[0]
            names.append(filename)
            categories.append(i)
            r_name.append(trans[doc])
        i+=1
    df = pd.DataFrame({
        'filename': names,
        'category': categories,
        'full name':r_name
    })

    total_train =df.shape[0]
    batch_size=1

    validation_split=0.0
    datagen = ImageDataGenerator(
        rescale=1. / 255, #Значения цвета меняем на дробные показания
        rotation_range=10, #Поворачиваем изображения при генерации выборки
        width_shift_range=0.1, #Двигаем изображения по ширине при генерации выборки
        height_shift_range=0.1, #Двигаем изображения по высоте при генерации выборки
        zoom_range=0.1, #Зумируем изображения при генерации выборки
        horizontal_flip=True, #Отключаем отзеркаливание изображений
        fill_mode='nearest', #Заполнение пикселей вне границ 
    )

    train_generator = datagen.flow_from_directory(
        path, 
        target_size=IMAGE_SIZE, #Размер изображений
        batch_size=batch_size, #Размер батча
        class_mode='categorical', #Разбиение выборки по материалу
        shuffle=True, #Перемешивание выборки
        subset='training' # устанавливаем как набор для обучения
    )

    epochs=1
    history_ = model.fit_generator(
        train_generator, 
        epochs=epochs,
        validation_steps=5,
        steps_per_epoch=1
    )


