'use strict'
MVPApp = -> # MVP приложение
    /* личный набор {{{
    *
    */
    /** CLONE {{{
    *
    * Глубокое клонирование (создание копии объекта)
    */
    CLONE = (obj, trace) ->
        # null/undefined/boolean/number/string/function/..
        if obj == null || typeof obj != 'object'
            # возвращаем как есть простые типы
            return obj

        # создаем клон на основе типа объекта
        switch typeof! obj
            | \Date =>
                return new Date obj.getTime!
            | \RegExp =>
                return new RegExp obj
            | \Array =>
                o = false
            | \Object =>
                # не копируем объекты jQuery
                if \jquery of obj
                    return obj
                o = true

            | otherwise =>
                console.warn 'CLONE fail:'+t
                return obj

        # сюда попадаем только в случае типа Array/Object:
        # используем трэйс чтобы не клонировать повторно
        if trace
            for x in trace when obj == trace[x]
                # возвращаем ссылку уже склонированного
                return obj
            trace[*] = obj
        else
            trace = [obj]

        # копия наследует прототип (зачем?)
        ##obj_clone = ^^obj
        # копия это простой объект, либо массив
        obj_clone = if o
            then {}
            else []

        # собираем данные
        if o
            for own x of obj
                obj_clone[x] = CLONE obj[x], trace
        else
            for x,i in obj
                obj_clone[i] = CLONE x, trace

        # возвращаем копию-клон
        obj_clone
    /** }}} */
    /** PARTIAL {{{
    *
    * Функция для техники частичного применения.
    * Возвращает функцию с "закрепленными" слева аргументами.
    */
    PARTIAL = (scope, func) ->
        # так как arguments это спец объект,
        # требуется его дополнительная обработка.
        args = if arguments.length > 2
            then Array.apply null, arguments .slice 2
            else []
        # возвращаем функцию с заданными аргументами
        ->
            # возвращаем конечный результат
            func.apply scope, args ++ (Array.apply null, arguments)

    /** }}} */
    /** PROXY {{{
    *
    * приложение основано на функциональности Прокси-объекта
    */
    PROXY = (obj, handler) ->
        # обработка исключений
        return try
            # метод клонирования прокси
            obj.clone = (o) ->
                o = if o
                    then (CLONE obj) <<< o
                    else CLONE obj
                PROXY o, handler
            # создаем
            p = new Proxy obj, handler
            # выполняем инициализацию (при необходимости)
            handler.init.apply p if handler.init
            # возвращаем объект
            p
        catch
            # еще отладки?
            console.log 'unhandled'
            console.log e
            null
    /** }}} */
    /** BOUNCE {{{
    *
    * Откладываем выполнение функции на заданное время.
    */
    BOUNCE = (scope, timeout, args, func) ->
        return false if !func or !scope
        # таймаут по-умолчанию
        timeout = 100 if !timeout
        # закрепляем в функции специальное свойство
        func.bounce = {} if !func.bounce
        # генерируем уникальный идентификатор
        do
            id = 'x'+Math.random().toString(36).substr(2, 16)
        while func.bounce[id]
        # определяем промежуточную функцию
        runme = !->
            # удаляем таймер
            delete func.bounce[id]
            # выполняем функцию
            func.apply scope, args
        # ставим таймер
        func.bounce[id] = window.setTimeout runme, timeout
        true
    /** }}} */
    /** THREAD {{{
    *
    * Выполняем функции последовательно, нитью, цепочкой или потоком
    */
    THREAD = (funcs, a) !->
        # определяем индекс функции в массиве
        !a and a = 0
        # выполняем функцию
        x = funcs[a]!
        if x == false
            # повтор
            window.setTimeout THREAD, 40, funcs, a
        else if x == true
            # продолжаем
            THREAD funcs, a if !!funcs[++a]
    /** }}} */
    /** CURRY {{{
    *
    * пример техники каррирования
    *
    *   add (a, b) ->
    *       a + b
    *
    *   add 3, 4 # =7
    *
    *   This is a function that takes two arguments, a and b, and returns their sum.
    *   We will now curry this function:
    *
    *   add (a) ->
    *       (b) ->
    *           a + b
    *
    *   This is a function that takes one argument, a,
    *   and returns a function that takes another argument, b,
    *   and that function returns their sum.
    *
    *   add(3)(4) # =7
    *   add3 = add(3)
    *   add3(4) #=7
    *
    /** }}} */
    /* MY (набор вспомогательных функций) {{{
    */
    MY = {
        randomInt: (min = 0, max = 1) -> # случайное число в заданных пределах {{{
            # проверка
            return max if min > max
            # подготовка
            min = Math.ceil min
            max = Math.random() * (Math.floor(max) - min + 1) + min
            # возврат
            Math.floor max
        # }}}
        uniqueArray: (a) -> # уникальный массив {{{
            a.filter (val, index, self) ->
                index == self.indexOf val
        # }}}
        measureText: (txt, font) -> # ширина текста в пикселях {{{
            # создаем объект
            a = document.createElement 'canvas' .getContext '2d'
            a.font = font
            # измеряем
            a.measureText txt .width
        # }}}
    }
    /* }}} */
    /* }}} */
    ###
    /* [M]odel {{{
    */
    M = {
        # сессия {{{
        authorized: false # авторизация, флаг
        # }}}
        nav: PROXY { # навигация {{{
            # архив
            arch: []

            # данные (значения по-умолчанию)
            data: [
                {
                    id: '' # начальный уровень навигации
                    panel: true # cостояние левой панели: раскрыта/свернута
                }
                {
                    id: ''
                }
                {
                    id: ''
                }
                {
                    id: ''
                }
            ]

            # восстанавливать уровни при переключениях
            restore: true

            # массив ключевых значений
            keys: -> @data.map (.id)
        }, {
            init: -> # {{{
                for a from 0 to @data.length - 1
                    @arch[a] = {'': CLONE @data.slice a + 1}
                true
            # }}}
            set: (obj, p, v, prx) -> # переключатель {{{
                # проверка
                if typeof p != 'string' or isNaN parseInt p
                    # свойство не является числовым, сохраняем как есть
                    obj[p] = v
                    return true
                # определяем номер уровня
                p = +p
                n = obj.data.length
                return true if p < 0 or p >= n
                # определяем ключевое значение уровня
                w = obj.data[p].id
                return true if w == v == ''
                # сбрасываем значение при совпадении!
                v = '' if v == w
                # сохраняем данные вышестоящих уровней в архив
                # только для непустого ключа!
                if w
                    obj.arch[p][w] = obj.data.slice p + 1, n
                # восстанавливаем данные
                # определяем ключ
                a = if obj.arch[p][v] and obj.restore
                    then v
                    else '' # пустой ключ существует всегда!
                # удаляем вышестоящие уровни
                obj.data.splice p + 1, n
                # дополняем из архива
                obj.data = obj.data ++ CLONE obj.arch[p][a]
                # сохраняем новое значение
                obj.data[p].id = v
                true
            # }}}
            get: (obj, p, prx) -> # данные уровня {{{
                # проверка
                if typeof p != 'string' or isNaN parseInt p
                    # возвращаем как есть
                    return obj[p]
                # определяем номер уровня
                p = +p
                return null if p < 0 or p >= obj.data.length
                # возврат уровня
                obj.data[p]
            # }}}
        }
        # }}}
    }
    /** }}} */
    /* [V]iew {{{
    */
    V = {
        nav: M.nav.clone {restore: false} # навигация
        state: 0 # состояние представления (число исполняемых потоков)
        timer: null # таймер setTimeout
        ###
        init: -> # {{{
            # сброс навигации
            for a in @nav.data
                a.id = '*'
            # загрузка цвета
            return false if not @color.init!
            # проверка
            if @init.state
                # выход
                return true
            # вход
            # блокируем вход
            @init.state = true
            # загружаем цвета
            @color.init!
            # загружаем рабочую область
            @skeleton.wa = $ '#wa'
            # возврат
            true
        # }}}
        refresh: (onComplete) -> # {{{
            # подготовка
            me = @
            me.state++
            # запуск
            V.skeleton.run \refresh, @nav.keys!, !->
                # функция завершена
                me.state--
                onComplete! if onComplete
            /*
            t = t ++ [ # сброс + ожидание {{{
                ->
                    # рабочая область (общий стиль)
                    # тип интерфейса
                    V.wa.removeClass \auth if not V.auth
                    V.wa.removeClass \std if V.auth
                    # навигация
                    for a,b in v when not a
                        V.wa.removeClass 'n'+b
                    # левая панель
                    w2ui.wa.refresh \left
                    # ok
                    true
            ]
            # }}}
            THREAD t ++ [ # {{{
                ->
                    # тулбар
                    # заголовок
                    gs.setTitle if V.auth or not v.0
                        then 1
                        else if v.0
                            then 2
                            else 0
                    # главная панель
                    # фон
                    a = if v.2
                        then ['' '']
                        else if V.auth
                            then ['gr2' '']
                            else if v.1
                                then ['gr0' 'gr1']
                                else ['gr0' '']
                    gs.setBackground a, !->
                        # грид
                        if V.grid
                            w2ui.grid.refresh! if w2ui.grid
                            V.grid.show!
                            V.gridControls.show!
                        # авторизация
                        if V.auth
                            V.auth.show!
                    # рабочая область (общий стиль)
                    V.wa.toggleClass \ok, true # начальная установка
                    V.wa.toggleClass \auth, !V.auth # авторизация выполнена
                    # навигация
                    for a,b in v
                        V.wa.toggleClass 'n'+b, !!a
                        for own c of V.nav[b] when c != \id
                            V.wa.toggleClass 'n'+b+''+c, !!V.nav[b][c]
                    # функция завершена
                    me.state = false
                    onComplete.apply me if onComplete
                    true
            ] # }}}
            */
            # возврат
            true
        # }}}
        resize: (delay, onComplete) !-> # {{{
            # подготовка
            me = @
            if delay or me.state != 0
                # исключаем повторный запуск и запуск во время обновления
                # +защита от множественных срабатываний (+debounce)
                # данная функция
                fn = me.resize
                # сброс таймера
                delay = 250 if not delay
                window.clearTimeout fn.timer if fn.timer
                # откладываем
                fn.timer = window.setTimeout (PARTIAL @, me, 0, onComplete), delay
            else
                # запуск
                me.state++
                V.skeleton.run \resize, @nav.keys!, !->
                    me.state--
                    onComplete! if onComplete
            # возврат
            true
            ##
            /*
            if @auth
                # авторизация!
                # определяем размер поля
                a = V.s.canvas
                a.outerWidth @view.outerWidth!
                a.outerHeight @view.outerHeight!
                # запуск
                gs.auth.init!
            # завершаем
            me.state = false
            */
        # }}}
        ###
        skeleton: PROXY { # дерево интерфейса {{{
            cfg:
                cfg: {} # обязательно для контейнера
                wa: # рабочая область {{{
                    init: ->
                        # подготовка
                        me = @
                        ls = V.skeleton.list!
                        # выполняем инициализацию корневых элементов
                        for a in ls when (b = $ '#' + a).length != 0
                            # подключаем к интерфейсу
                            V.skeleton[a] = b
                            # скрыты по-умолчанию
                            V[a].hide {time: 0}
                        # стыкуем обработчкики
                        # изменение размеров окна
                        $ window .on 'resize.' + @0.id, ->
                            V.resize 100, ->
                                V.refresh!
                        # рабочая область по-умолчанию скрыта,
                        # отображаем
                        me.show !->
                            # отображаем корневые элементы
                            for a in ls when V[a]
                                V[a].show!
                        # возврат
                        true
                # }}}
                toolbar: # тулбар {{{
                    cfg:
                        init: -> # {{{
                            # подготовка
                            me = @
                            # постоянные элементы
                            me.pb = $ '#toolbar .ui-progressbar' .progressbar {value: 0}
                            true
                        # }}}
                    # кнопы режима
                    mode:
                        cfg:
                            init: -> # {{{
                                # подготовка
                                debugger
                                me = @
                                # ...
                                # возврат
                                true
                            # }}}
                            attach: -> # {{{
                                # переключение режима
                                for a in V.skeleton.list @0.id
                                    @[a].click ->
                                        P.setNav 0, @id
                                # возврат
                                false
                            # }}}
                            detach: -> # {{{
                                # отстыковка
                                for a in V.skeleton.list @0.id
                                    @[a].off!
                                # возврат
                                false
                            # }}}
                            refresh: (v, onComplete) -> # {{{
                                # проверка
                                debugger
                                /*
                                if v.0
                                    # устанавливаем стиль кноп
                                    for a,b in me.btn
                                        me.m_btn.eq(b).toggleClass \on,  a.id == v.0
                                        me.m_btn.eq(b).toggleClass \off, a.id != v.0
                                else
                                    # сбрасываем стиль
                                    s.m_btn.removeClass 'on off'
                                */
                                # возврат
                                true
                            # }}}
                            resize: (v, onComplete) -> # {{{
                                debugger
                                # определяем текст
                                for a in V.skeleton.list @0.id
                                    b = @[a]

                                me.m_btn.outerWidth (index, width) ->
                                    # наименование
                                    c = V[@id].cfg
                                    if V.auth
                                        @innerHTML = ''
                                    else if width > c.ss
                                        @innerHTML = c.n
                                    else
                                        @innerHTML = c.sn
                                    # ok
                                    width
                                # возврат
                                true
                            # }}}
                        ###
                        m1:
                            n: 'Управление'
                            sn: 'Упр'
                            ss: 130
                        m2:
                            n: 'Входящие'
                            sn: 'Вхд'
                            ss: 130
                        m3:
                            n: 'Исходящие'
                            sn: 'Исх'
                            ss: 130
                    # заголовок
                    title:
                        cfg: {}
                # }}}
                #
                todo:
                    panel: # панель навигации {{{
                        cfg:
                            init: -> # {{{
                                # подготовка
                                me = @
                                id = @0.id
                                # постоянные элементы
                                me.resizer = $ '#layout_wa_resizer_left'
                                # общие методы
                                me.func = {
                                    attach: (lv, m) -> # {{{
                                        # проверка
                                        return false if not m.0
                                        # опрдеделяем обработчики событий
                                        # сворачивание-разворачиванеие панели
                                        me.resizer.click !->
                                            P.nav 0, \panel, !V.nav.0.panel
                                        # выбран переключатель
                                        if m.2
                                            # определяем выбранный
                                            me.a_sw.filter ->
                                                @id == m.2
                                            .prop \checked, true
                                            # устанавливаем дополнительный стиль
                                            me.resizer.on 'mouseenter.' + id, !->
                                                V.view.addClass \sel
                                            me.resizer.on 'mouseleave.' + id, !->
                                                V.view.removeClass \sel
                                        ###
                                        me.func.detach = (lv, m) -> # разборка {{{
                                            # удаление вспомогательных обработчиков
                                            lv.2 and me.resizer.off id
                                            # удаление аккордеона
                                            lv.0 and me.hide !->
                                                # отстыковка обработчиков
                                                me.off
                                                me.a_sw.off!
                                                # удаляем
                                                me.accordion \destroy
                                                # зачищаем контент
                                                me.load!
                                            # возврат
                                            delete me.func.detach
                                            true
                                        # }}}
                                        true
                                    # }}}
                                    refresh: -> # {{{
                                        # панель
                                        # скрываем
                                        a = \left
                                        b = w2ui.wa.get a .hidden
                                        if V.auth or not V.nav.0.id
                                            w2ui.wa.hide a if not b
                                            return true
                                        # отображаем
                                        w2ui.wa.show a if b
                                        # панель задвинута
                                        return true if not V.nav.0.panel
                                        # аккордеон
                                        # пересчет стилей
                                        me.accordion \refresh
                                        # панели аккордеона
                                        # верхняя
                                        if me.a_panel.length > 0
                                            me.a_panel.eq(0).addClass \top
                                        # нижняя
                                        if me.a_panel.length > 1
                                            me.a_panel.eq(-1).addClass \bottom
                                        # определяем активную панель
                                        a = if v.1
                                            then V.skeleton.index v.1
                                            else false
                                        # задаем стиль не-активных панелек
                                        if a != false
                                            me.a_panel.addClass \faded
                                            me.a_panel.filter (index, el) ->
                                                index == a
                                            .removeClass \faded
                                        else
                                            me.a_panel.removeClass \faded
                                        # под активной
                                        me.a_panel.removeClass \below
                                        if a != false and a + 1 < me.a_panel.length - 1
                                            me.a_panel.eq(a + 1).addClass \below
                                        # содержимое
                                        # переключатели представления данных
                                        if V.nav.2.id
                                            for a,b in me.a_box
                                                me.a_box.eq(b).toggleClass \on, a.checked
                                                me.a_box.eq(b).toggleClass \off, not a.checked
                                        else
                                            me.a_box.removeClass 'on off'
                                        # отображаем панель
                                        me.show!
                                        # возврат
                                        true
                                    # }}}
                                    resize: -> # {{{
                                        # подготовка
                                        return true if not (v = V.nav.0).id
                                        if v.panel
                                            # панель выдвинута
                                            a = V.toolbar.m_box.outerWidth! + w2ui.wa.resizer + 4
                                            me.accordion \refresh if me.reset
                                        else
                                            # панель свернута
                                            a = 0
                                        # корректируем
                                        # определяем размер панели
                                        if Math.abs(me.outerWidth! - a) > 0
                                            w2ui.wa.sizeTo \left, a
                                        # возврат
                                        true
                                    # }}}
                                }
                                true
                            # }}}
                            create: -> # создание аккордеона {{{
                                # подготовка
                                me = V[@id]
                                # дочерние элементы
                                me.a_panel = $ '#panel div.aPanel' # панели-заголовки внутри аккордеона
                                me.a_box = $ '#panel label.swBox' # контейнер переключателя
                                me.a_sw = $ '#panel input.swInput' # переключатель
                                # метод удаления/сброса
                                me.reset = !->
                                    me.hide !->
                                        # отстыковка обработчиков
                                        me.off '.a'
                                        me.a_sw.off!
                                        # удаляем
                                        me.accordion \destroy
                                        # удаляем метод
                                        delete me.reset
                                        # зачищаем контент
                                        me.load!
                                # стыковка обработчиков событий
                                # активация панели аккордеона
                                me.on 'accordionbeforeactivate.a', (e, ui) ->
                                    # проверка
                                    if P.sync.state
                                        e.stopPropagation!
                                        return false
                                    # определяем идентификатор панели
                                    a = if ui.newHeader.length == 0
                                        then ''
                                        else ui.newHeader.0.id
                                    # действие
                                    P.setNav 1, a
                                    true
                                # переключатели
                                # выбор
                                me.a_sw.change (e) ->
                                    # проверка
                                    if P.sync.state or V.refresh.state
                                        e.stopPropagation!
                                        return false
                                    # действие
                                    if @type == \radio
                                        P.setNav 2, @id
                                    # возврат
                                    true
                                # отключение всей группы
                                me.a_sw.click (e) ->
                                    # проверка
                                    if P.sync.state or V.refresh.state
                                        # отмена события
                                        e.stopPropagation!
                                        return false
                                    # действие
                                    if @type == \radio and V.nav.2.id == @id
                                        @checked = false
                                        P.setNav 2, @id
                                    # возврат
                                    true
                                # возврат
                                true
                            # }}}
                            ###
                            collapsible: true
                            heightStyle: \fill
                            icons: false
                            header: '.aPanel'
                        # панели аккордеона
                        m1v1:
                            cfg:
                                n: '1'
                            m1v1f1:
                                n: '1-1'
                            m1v1f2:
                                n: '1-2'
                        m1v2:
                            cfg:
                                n: '2'
                            m1v2f1:
                                n: '2-1'
                            m1v2f2:
                                n: '2-2'
                            m1v2f3:
                                n: '2-3'
                            m1v2f4:
                                n: '2-4'
                        m2v1:
                            cfg:
                                n: 'Картотека'
                            m2v1f1:
                                n: 'помещения'
                            m2v1f2:
                                n: 'дома'
                            m2v1f3:
                                n: 'микрорайоны/улицы'
                            m2v1f4:
                                n: 'районы'
                            m2v1f5:
                                n: 'города'
                        m2v4:
                            cfg:
                                n: 'Потребители'
                            m2v4f1:
                                n: 'частные лица'
                            m2v4f2:
                                n: 'организации'
                        m2v2:
                            cfg:
                                n: 'Оплата'
                            m2v2f1:
                                n: 'касса'
                            m2v2f2:
                                n: 'банк'
                            m2v2f3:
                                n: 'взаимозачет'
                            m2v2f4:
                                n: 'сторно'
                        m2v3:
                            cfg:
                                n: 'Объемы'
                            m2v3f1:
                                n: '3-1'
                            m2v3f2:
                                n: '3-2'
                            m2v3f3:
                                n: '3-3'
                        m2v5:
                            cfg:
                                n: 'Поставщики'
                            m2v5f1:
                                n: '5-1'
                            m2v5f2:
                                n: '5-2'
                        m3v1:
                            cfg:
                                n: 'Отчеты'
                            m3v1f1:
                                n: '1-1'
                            m3v1f2:
                                n: '1-2'
                        m3v2:
                            cfg:
                                n: 'Запросы'
                            m3v2f1:
                                n: '2-1'
                            m3v2f2:
                                n: '2-2'
                    # }}}
                    view: # представление данных {{{
                        cfg:
                            init: -> # {{{
                                # подготовка
                                me = @
                                # постоянные элементы
                                # ..
                                # общие методы
                                me.func = {
                                    attach: -> # {{{
                                        ###
                                        # возврат
                                        me.func.detach = -> # {{{
                                            # возврат
                                            delete me.func.detach
                                            true
                                        # }}}
                                        true
                                    # }}}
                                    refresh: -> # {{{
                                        # возврат
                                        me.show!
                                        true
                                    # }}}
                                    resize: -> # {{{
                                        # возврат
                                        true
                                    # }}}
                                }
                                # возврат
                                true
                            # }}}
                        auth: # авторизация {{{
                            cfg:
                                preInit: false
                        # }}}
                        grid: # грид {{{
                            # конфигурация
                            cfg:
                                preInit: false
                                name: \grid
                                show:
                                    header         : false # indicates if header is visible
                                    toolbar        : false # indicates if toolbar is visible
                                    footer         : true # indicates if footer is visible
                                    columnHeaders  : true # indicates if columns is visible
                                    lineNumbers    : false # indicates if line numbers column is visible
                                    expandColumn   : false # indicates if expand column is visible
                                    selectColumn   : false # indicates if select column is visible
                                    emptyRecords   : true # indicates if empty records are visible
                                    toolbarReload  : true # indicates if toolbar reload button is visible
                                    toolbarColumns : true # indicates if toolbar columns button is visible
                                    toolbarSearch  : true # indicates if toolbar search controls are visible
                                    toolbarAdd     : true # indicates if toolbar add new button is visible
                                    toolbarEdit    : true # indicates if toolbar edit button is visible
                                    toolbarDelete  : true # indicates if toolbar delete button is visible
                                    toolbarSave    : true # indicates if toolbar save button is visible
                                    selectionBorder: true # display border around selection (for selectType = 'cell')
                                    recordTitles   : true # indicates if to define titles for records
                                    skipRecords    : true # indicates if skip records should be visible

                            m1v1f1g: {}
                            m2v2f1g:
                                columns: [
                                    {
                                        caption: 'ID'
                                        field: 'recid'
                                        hidden: true
                                    }
                                    {
                                        caption: '№ пачки'
                                        field: 'rName'
                                        size: '40%'
                                        sortable: true
                                    }
                                    {
                                        caption: 'тип'
                                        field: 'rType'
                                        size: '10%'
                                        attr: 'align=center'
                                    }
                                    {
                                        caption: 'количество'
                                        field: 'rCnt'
                                        size: '20%'
                                        attr: 'align=right'
                                    }
                                    {
                                        caption: 'сумма'
                                        field: 'rSum'
                                        size: '20%'
                                        attr: 'align=right'
                                    }
                                    {
                                        caption: 'дата'
                                        field: 'rDate'
                                        size: '10%'
                                        sortable: true
                                        attr: 'align=center'
                                    }
                                ]
                                sortData: [
                                    {
                                        field: 'rName'
                                        direction: 'ASC'
                                    }
                                ]
                                records: [
                                    {
                                        recid: 1
                                        rName: 'XXXXXXXX'
                                        rType: 'KZT'
                                        rCnt: '733'
                                        rSum: '3247192.22'
                                        rDate: '2017/01/01'
                                    }
                                    {
                                        recid: 2
                                        rName: 'YYYYYYYY'
                                        rType: 'KZT'
                                        rCnt: '433'
                                        rSum: '156000.00'
                                        rDate: '2016/12/30'
                                    }
                                    {
                                        recid: 3
                                        rName: 'ZZZZZZZZ'
                                        rType: 'KZT'
                                        rCnt: '84'
                                        rSum: '95000.00'
                                        rDate: '2017/01/15'
                                    }
                                ]
                                /*
                                */
                        # }}}
                        gridControls: # контролы {{{
                            cfg: {}
                            m2v2f1gc:
                                list: [
                                    {n: \добавить}
                                    {n: \удалить}
                                    {n: \изменить}
                                ]
                        # }}}
                        ##
                    ######
                    # }}}
                    console: # консоль {{{
                        cfg:
                            # слайдер цвета
                            ifColor:
                                n0: 'Цвет'
                                n1: '»'
                                ##
                                animate: true
                                disabled: false
                                min: 0
                                max: 360
                                create: ->
                                    # подготовка контрола
                                    true
                                slide: (e, ui) !->
                                    # слайдинг
                                    # выводим текущее значение
                                    V.note.text ui.value
                                stop: (e, ui) ->
                                    # слайдинг завершен
                                    true
                        # короткое сообщение
                        note:
                            cfg: {}
                        # кнопа-слайдер
                        sliderBtn:
                            cfg:
                                # метод инициализации
                                init: (cfg) ->
                                    # подключаем дочерние элементы
                                    a = '#' + @0.id
                                    @scale  = $ a + ' div.ui-slider'
                                    @handle = $ a + ' div.ui-slider .ui-slider-handle'
                                    @btn0   = $ a + ' button.accept' .button!
                                    @btn1   = $ a + ' button.restore' .button!
                                    # создаем
                                    @btn0.text cfg.n0
                                    @btn1.text cfg.n1
                                    @scale.slider cfg
                                    # ok
                                    true
                    # }}}
            ###
            _seek: (cid, node, path, pid) -> # поиск элемента {{{
                #
                # cid  - искомый идентификатор
                # node - элемент-контейнер
                # path - полный путь к искомому
                # pid  - идентификатор предыдущей кости
                #
                # если отсутствует конфигурация, то
                # данный элемент (pid) последний (лист дерева) и
                # не является контейнером.
                if node.cfg
                    # проверяем текущий набор
                    if node[cid]
                        # найдено!
                        path.unshift pid if pid and path
                        return node[cid]
                    # рекурсия
                    # спускаемся вниз по дереву
                    for a of node when b = @_seek cid, node[a], path, a
                        path.unshift pid if pid and path
                        return b
                # объект не найден..
                null
            # }}}
            ###
            path: (id) -> # полный путь до элемента в дереве {{{
                # подготовка
                path = []
                return path if not id
                # поиск
                @_seek id, @cfg, path
                # возврат
                path
            # }}}
            list: (id) -> # список дочерних элементов {{{
                if not id
                    # корневые элементы
                    # все, кроме рабочей области
                    a = Object.keys @cfg .filter (b) ->
                        b != \wa and b != \cfg
                else
                    # извлекаем контейнер
                    if (a = @_seek id, @cfg) and a.cfg
                        # все, кроме конфигурации
                        a = Object.keys a .filter (b) -> b != \cfg
                    else
                        # не контейнер
                        a = []
                # возврат
                a
            # }}}
            index: (id) -> # {{{
                # проверка
                return false if not id
                # определяем список дочерних элементов родителя
                if (a = @path id).length > 0
                    a = @list a.pop!
                else
                    a = @list!
                    true
                # определяем собственный индекс в списке
                # возврат
                a.indexOf id
            # }}}
            run: (method, ...args, onComplete) -> # запуск общей функции {{{
                # подготовка
                me = @
                x = 0
                args.push !-> --x
                # запускаем поток
                THREAD [
                    ->
                        # выполняем для корневых элементов
                        for a in me.list! when V[a]
                            x++
                            V[a].func[method].apply V[a], args
                        # далее
                        true
                    ->
                        # ожидаем
                        x == 0
                    ->
                        # метод выпoлнен
                        onComplete! if onComplete
                        true
                ]
                # возврат
                true
            # }}}
        }, {
            get: (obj, id, prx) -> # извлечение {{{
                # проверка
                return null if not id
                # возвращаем как есть
                return obj[id] if obj[id]
                # возврат
                obj._seek id, obj.cfg
            # }}}
            set: (obj, p, v, prx) -> # загрузка {{{
                /*
                *   p == имя элемента в дереве интерфейса
                *   v == обертка элемента jQuery
                */
                # подготовка
                # определяем конфигурацию элемента
                return false if !p or !v or not a = prx[p]
                v.cfg = if a.cfg then a.cfg else a
                # список дочерних элементов
                lst  = obj.list p
                # путь до элемента
                path = obj.path p
                # шаблон
                templ = if (a = $ '#'+p+'-t').length != 0
                    then a.html!
                    else ''
                # определяем методы
                init = (id) -> # инициализация {{{
                    # проверка
                    if templ and id
                        # динамический элемент
                        # функция определения параметров
                        params = (cid, pid) ->
                            # результирующая структура (дерево)
                            a =
                                id: cid     # идентификатор
                                pid: pid    # родительский идентификатор
                            # добавляем шаблон
                            # только для искомого (первого) элемента
                            if not pid and (b = $ '#'+cid+'-t').length == 1
                                a.html = b.html!
                            # извелкаем элемент из дерева
                            if b = prx[cid]
                                # добавляем параметры
                                if b.cfg
                                    # конфигурация
                                    a <<< b.cfg
                                    # определяем контейнер параметров дочерних элементов
                                    a.body = []
                                    for c of b when c != \cfg
                                        # рекурсия
                                        a.body.push params c, cid
                                else
                                    # все содержимое
                                    a <<< b
                            # возврат
                            a
                        # на основе шаблона и параметров,
                        # формируем контент
                        v.html Mustache.render templ, params id
                        ###
                    else if templ
                        # динамический элемент
                        # шаблон без параметров
                        v.html Mustache.render templ, {}
                        # идентификатор
                        id = @0.id
                    else
                        # статичный элемент
                        # идентификатор
                        id = @0.id
                    # сборка дочерних элементов
                    for a in obj.list id when (b = $ '#' + a).length != 0
                        # инициализация (рекурсия)
                        prx[a] = b
                    # контент загружен
                    # выполняем частную инициализацию элемента
                    if v.cfg.init
                        return v.cfg.init.apply v
                    # возврат
                    true
                # }}}
                fn = (method, dive, ...args, onComplete) -> # функция-шаблон {{{
                    # определяем счетчик
                    x = 0
                    args.push !-> --x # завершающая функция-декремент
                    # определяем функции потока
                    # текущий элемент
                    if v.cfg[method]
                        f1 = [
                            ->
                                # частный метод
                                # положительный возврат гарантирует вызов завершающей функции
                                x++ if v.cfg[method].apply v, args
                                # далее
                                true
                            ->
                                # ожидаем
                                x == 0
                        ]
                    else
                        f1 = []
                    # дочерние элементы
                    f2 = [
                        ->
                            # общий метод
                            for a in lst when v[a]
                                x++ if v[a].func[method].apply v, args
                            # далее
                            true
                        ->
                            # ожидаем
                            x == 0
                    ]
                    # определяем порядок обхода
                    # комбинируем
                    a = if dive
                        then f1 ++ f2 # погружение
                        else f2 ++ f1 # всплытие
                    # запускаем поток
                    THREAD a ++ [
                        ->
                            # завершено
                            onComplete! if onComplete
                            true
                    ]
                    # возврат
                    true
                # }}}
                # подключаем методы
                v.func =
                    # инициализация
                    init: PARTIAL v, init
                    # события
                    attach: PARTIAL v, fn, \attach, true
                    detach: PARTIAL v, fn, \detach, false
                    # обновление
                    refresh: PARTIAL v, fn, \refresh, true
                    # изменение размеров
                    resize: PARTIAL v, fn, \resize, false
                # добавляем общие методы
                # отображение
                v.show = PARTIAL v, V.GSAP.show
                # скрытие
                v.hide = PARTIAL v, (a, b) ->
                    V.GSAP.show.apply v, [a <<< {show:false}, b]
                # методы подключены
                # поиск контейнера
                node = V
                for a in path
                    break if not node[a]
                    node = node[a]
                # вставка
                node[p] = v
                # не корневой контейнер в интерфейсе, может содержать
                # в себе только один контейнер (один навигационный маршрут),
                # остальные контейнеры следует отключить от интерфейса..
                if path.length != 0
                    for a in lst when a != p and node[a] and prx[a].cfg
                        # отключаемые элементы являются контейнерами
                        node[a].remove!
                        delete node[a]
                # инициализация
                v.func.init!
                # возврат
                true
            # }}}
        }
        # }}}
        ###
        GSAP: # greensock-js {{{
            # данные
            busy: 0 # счетчик активных анимаций
            ###
            show: (args = {}, onComplete) -> # отображение/скрытие элемента {{{
                # подготовка
                if typeof args == \function
                    onComplete = args
                    args = {}
                if args.show == undefined
                    args.show = true
                if args.time == undefined
                    # время появления || скрытия по-умолчанию
                    args.time = if args.show then 0.8 else 0.4
                me = @
                gs = V.GSAP
                op = if args.show then 1 else 0
                # останавливаем текущую анимацию
                me.onComplete! if me.onComplete
                # проверяем необходимость
                if args.time > 0
                    # используем inline-стиль (быстрее)
                    a = me.0.style.opacity
                    a = if not a
                        then 0
                        else +a
                    # проверка
                    return true if a == op
                else
                    # анимация не требуется (мгновенно)
                    TweenMax.set me, {opacity:op}
                    return true
                # подготовка анимации
                gs.busy += 1
                # метод останова
                me.onComplete = !->
                    # анимация завершена
                    me.anim.kill!
                    gs.busy -= 1
                    onComplete! if onComplete
                    delete me.anim
                # таймлайн
                me.anim = new TimelineLite {
                    paused: true
                    onComplete: me.onComplete
                }
                if args.show
                    # отображаем
                    me.anim.to me, args.time, {
                        opacity:1
                        ease:Power1.easeOut
                    }, 0
                else
                    # скрываем
                    me.anim.to me, args.time, {
                        opacity:0
                        ease:Power1.easeIn
                    }, 0
                # запуск
                me.anim.play!
                true
            # }}}
            color: (Hue) -> # изменяет цвет интерфейса {{{
                # ...
                # устанавливаем
                V.color.set Hue
                # обновляем стили
                V.refresh!
            # }}}
            ### TODO
            setBackground: (bg, onComplete) -> # фон представления данных {{{
                # подготовка
                me = @setBackground
                gs = @
                d = V.view # анимируемый элемент
                # проверка
                if not d or not bg and not me.bg
                    return false
                if not bg
                    # параметр не задан
                    bg = me.bg
                    # повторная установка
                    delete me.bg
                else
                    # определяем значение градиента
                    a = []
                    for b in bg when b
                        a.push V.color[b]
                    bg = if a.length > 0
                        then a.join ' , '
                        else 'none'
                # проверка необходимости
                if me.bg and me.bg == bg
                    # возврат
                    onComplete! if onComplete
                    return false
                # останавливаем текущую анимацию
                me.state.vars.onComplete.apply me.state if me.state
                # таймлайн
                a = new TimelineLite {
                    paused: true
                    onComplete: !->
                        # анимация завершена
                        @kill!
                        gs.busy -= 1
                        # сохряняем параметр
                        me.bg = bg
                        # завершаем
                        onComplete! if onComplete
                        delete me.state
                }
                t0 = 0
                t1 = 0.8 # появление
                t2 = 0.4 # сркытие
                # скрываем
                if d.0.style.opacity != '0'
                    # при проверке прозрачности используем свойство DOM-элемента,
                    # так-как это быстрее, однако, оно работает корректно
                    # только при наличии inline-стиля.
                    if me.bg == 'none'
                        # немедленно
                        a.set d, {opacity:0}, t0
                    else
                        # плавно
                        a.to d, t2, {
                            opacity:0
                            ease:Power1.easeIn
                        }, t0
                        t0 += t2
                # отображаем
                if bg == 'none'
                    # немедленно
                    a.set d, {backgroundImage:'none', opacity:1}, t0
                else
                    # плавно
                    a.set d, {backgroundImage:bg}, t0
                    a.to d, t1, {
                        opacity:1
                        ease:Power1.easeOut
                    }, t0
                # запуск анимации
                me.state = a
                gs.busy += 1
                a.play!
                true
            # }}}
            setTitle: (num = 0) -> # задаем инфо-заголовок {{{
                # подготовка
                me = @setTitle
                # определяем текст
                a = V.lang.title[num]
                a = a! if typeof a != 'string'
                # проверяем необходимость
                return false if me.txt == a
                # запоминаем
                me.txt = a
                # анимация (TODO)
                V.title.html a
                # ok
                false
            # }}}
            setNote: (num = 0) -> # задаем инфо-заметку {{{
                # подготовка
                me = @setNote
                # определяем текст
                a = V.lang.note[num]
                # фиксируем параметры
                return false if me.num == num
                me.num = num
                # анимация (TODO)
                V.note.html a
                # ok
                false
            # }}}
            auth: -> # авторизация (TODO:rev) {{{
                # подготовка
                me = @auth
                gs = @
                return false if me.state
                # излучатель {{{
                # данные и настройки
                dt =
                    anim: null     # эффекты
                    radius:  4     # радиус излучателя (добавка к!)
                    R: 0           # настоящий радиус определяется контекстом
                    timeout: 4     # таймаут пассивного излучения (сек)
                    p_count: 0     # кол-во частиц
                    p_size0: 0.5   # минимальный размер частицы
                    p_size1: 2.0   # максимальный размер частицы
                    p_speed: 5     # начальная скорость частицы
                    p_acc: 0.00005 # ускорение частицы
                    stars: []      # массив частиц
                # отрисовка
                render = ->
                    # подготовка
                    # определяем размер полотна
                    a  = V.s.canvas.0
                    cw = a.width
                    ch = a.height
                    # определяем центр
                    cx = cw / 2
                    cy = ch / 2

                    # создание частиц
                    for a from 1 to dt.p_count
                        r0 = Math.random!
                        r1 = Math.random! + 0.2*r0 # большие частицы летят быстрее
                        r2 = 360 * Math.random!
                        dt.stars.push {
                            x: cx + dt.R * Math.cos(r2 * Math.PI / 180)
                            y: cy + dt.R * Math.sin(r2 * Math.PI / 180)
                            r: 1
                            size: dt.p_size0 + (dt.p_size1 - dt.p_size0)*r0
                            speed: 1 # начальная скорость
                            accel: 1 + (1 + dt.p_speed * r1)/1000 # начальное ускорение
                            angle: r2
                        }

                    # сбрасываем таймаут начального излучения
                    dt.timeout = 0 if dt.p_count > 0

                    # отрисовка
                    a = []
                    dt.ctx.clearRect 0, 0, cw, ch
                    while dt.stars.length
                        star = dt.stars.pop!
                        vx = star.speed * Math.cos(star.angle * Math.PI / 180)
                        vy = star.speed * Math.sin(star.angle * Math.PI / 180)
                        ##
                        dt.ctx.beginPath!
                        dt.ctx.lineWidth = star.size
                        dt.ctx.moveTo star.x, star.y
                        star.x = star.x + vx
                        star.y = star.y + vy
                        dt.ctx.lineTo star.x, star.y
                        dt.ctx.stroke!
                        # добавляем скорости
                        star.speed = star.speed * star.accel
                        star.accel = star.accel + dt.p_acc
                        # если частица не вылетела за пределы области,
                        # сохраняем ее для последующей отрисовки.
                        if star.x < cw and star.x > 0 and star.y < ch and star.y > 0
                            a.push star

                    # откладываем
                    dt.stars = a
                    true
                # }}}
                anim = -> # анимация (объеткы GSAP) {{{
                    # ноды
                    node = $ '#auth g.node *'
                    # инициализация
                    TweenMax.set V.s.auth_svg, {
                        boxShadow:'0px 0px 40px 8px ' + V.color.80
                    }
                    ##
                    return {
                        hover: do -> # наведение {{{
                            # инициализация
                            TweenMax.to node.2, 0, {
                                transformOrigin:'center'
                                fill:V.color.70
                                scale:0
                                force3D:true
                            }
                            # таймлайн
                            a = new TimelineLite {
                                paused: true
                                onStart: ->
                                    # изменяем EASE
                                    a = @getTweensOf node.2
                                    a.0.updateTo {ease:Power4.easeOut}
                                    # максимальное излучение
                                    dt.p_count = 5
                                    dt.p_speed = 25
                                    true
                                onComplete: ->
                                    # пауза
                                    @pause!
                                    # изменяем EASE
                                    a = @getTweensOf node.2
                                    a.0.updateTo {ease:Power4.easeIn}
                                    # запускаем дочерний эффект (пульсация)
                                    @vars.tw = TweenMax.to node.2, 0.5, {
                                        scale:0.77
                                        fill:V.color.80
                                        repeat:-1
                                        yoyo:true
                                        ease:Circ.easeIn
                                    }
                                    true
                                onReverse: ->
                                    true
                                onReverseComplete: ->
                                    # пауза
                                    @pause!
                                    true
                            }
                            # метод остановки дочернего эффекта
                            a.stopit = ->
                                # минимальное излучение
                                dt.p_count = 1
                                dt.p_speed = 5
                                # останавливаем пульсацию
                                if @vars.tw
                                    @vars.tw.kill!
                                    delete @vars.tw
                                true
                            # пристыковка
                            a.vars.onReverse = a.stopit
                            # определяем основной эффект
                            # тень svg
                            e = 0
                            f = Power2.easeInOut
                            b = TweenMax.to V.s.auth_svg, 0.4, {
                                boxShadow:'0px 0px 60px 10px ' + V.color.80
                                ease:f
                            }
                            a.add b, e + 0.1
                            # уменьшаем svg
                            d = 0.4
                            b = TweenMax.to V.s.auth_svg, d, {
                                scale: 0.97
                                ease:f
                            }
                            a.add b, e
                            # меняем градиенты svg
                            d = 0.8
                            a.to node.0, d, {
                                fillOpacity:0
                            }, e
                            a.to node.1, d, {
                                fillOpacity:1
                            }, e
                            # всплывающий кружок
                            b = TweenMax.to node.2, d, {
                                fill:V.color.90
                                scale:1
                            }
                            a.add b, e
                            ##
                            a
                            ## }}}
                        click: do -> # клик {{{
                            # круг => треугольник
                            TweenMax.to node.2, 0.5, {
                                paused:true
                                mSVG: {shape:node.5}
                                scale: 1
                                fill: V.color.87
                                ease: Back.easeOut
                                ##
                                onStart: ->
                                    # прогресс
                                    V.pb.eq(0).progressbar {value: 100}
                                    V.pb.eq(1).progressbar {value: 100}
                                    true
                                onComplete: ->
                                    # пауза
                                    @pause!
                                    # уменьшаем и замедляем излучение
                                    dt.p_count = 4
                                    dt.p_speed = 8
                                    # заголовок
                                    gs.setTitle 3
                                    true
                                onReverseComplete: ->
                                    # минимальное излучение
                                    dt.p_count = 1
                                    dt.p_speed = 5
                                    # прогресс
                                    V.pb.eq(0).progressbar {value: 0}
                                    V.pb.eq(1).progressbar {value: 0}
                                    # заголовок
                                    gs.setTitle 1
                                    true
                            }
                            ## }}}
                        wait: do -> # ожидание ответа сервера {{{
                            # вращение треугольника
                            a = TweenMax.to node.2, 2, {
                                rotation:-240
                                paused:true
                                repeat:-1
                                ease:Power3.easeInOut
                            }
                            # метод останова
                            a.stop = !->
                                @pause!
                                @stop.ok = false
                                TweenMax.to node.2, 1, {
                                    rotation:0
                                    ease:Power3.easeIn
                                    onComplete: !-> a.stop.ok = true
                                }
                            # ok
                            a
                            ## }}}
                        splash: do -> # сплэш! {{{
                            # таймлайн
                            a = new TimelineLite {
                                paused: true
                                onComplete: !->
                                    @pause!
                                onReverseComplete: !->
                                    @pause!
                            }
                            # предварительные установки
                            e = 0
                            a.set V.view, {
                                backgroundColor:V.color.95
                            }, e
                            a.set node.0, {
                                fill:'url(#gr4)'
                                fillOpacity:0
                            }, e
                            a.set node.1, {
                                fillOpacity:1
                            }, e
                            a.set node.3, {
                                transformOrigin:'center'
                                fill:V.color.80
                                scale:1.2
                            }, e
                            ##
                            # 1. остановка ожидания {{{
                            # останавливаем треугольник
                            d = 2
                            a.to node.2, d, {
                                rotation:0
                                fill:V.color.85
                                ease:Power3.easeInOut
                            }, e
                            # общий фон (сливается с градиентом)
                            a.to V.view, d, {
                                backgroundColor:V.color.90
                                ease:Power2.easeIn
                                onComplete: !->
                                    # убираем градиент
                                    a.set V.view, {backgroundImage:\none}
                                    true
                            }, e
                            # фон svg
                            a.to node.0, d, {
                                fillOpacity:1
                                ease:Power2.easeIn
                            }, e
                            a.to node.1, d, {
                                fillOpacity:0
                                ease:Power2.easeIn
                            }, e
                            # уменьшаем границу
                            a.to V.s.auth_svg, d, {
                                boxShadow:'0px 0px 6px 2px '+V.color.80
                            }, e
                            # }}}
                            # 2. базовое лого {{{
                            # отображаем кольцо
                            e = e + d - 0.5
                            a.to node.3, d, {
                                fillOpacity:1
                                scale:1
                                ease:Power3.easeInOut
                                onStart: ->
                                    gs.setNote 9
                                    true
                            }, e
                            # фон svg (сплошной)
                            e = e + d
                            a.set node.1, {
                                fill:V.color.95
                            }, e
                            a.to node.0, d, {
                                fillOpacity:0
                                ease:Power2.easeIn
                            }, e
                            a.to node.1, d, {
                                fillOpacity:1
                                ease:Power2.easeIn
                            }, e
                            # треугольник => лого
                            a.to node.2, 0.8, {
                                mSVG:
                                    shape:node.6
                                    shapeIndex:2
                                fill:V.color.80
                                ease:Back.easeOut
                            }, e - d
                            # }}}
                            # 3. лого, splash! {{{
                            # убираем подсветку границы
                            a.set V.s.auth_svg, {
                                clearProps:'boxShadow'
                                #boxShadow:'none'
                                onComplete: !->
                                    # workaround!
                                    V.s.auth_svg.css \box-shadow, \none
                                    gs.setNote 11
                            }, e
                            # общий фон
                            # так как установлен градинт, соответствующим
                            # цветом мы сливаем его в сплошой цвет.
                            f = Back.easeOut
                            d = 1.0
                            a.to V.view, d, {
                                backgroundColor:V.color.90
                                ease:f
                            }, e
                            # убираем градиент общего фона
                            a.set V.view, {backgroundImage:\none}, e + d
                            # фон svg (сливается с общим фоном)
                            a.set node.0, {fill:V.color.90}, e
                            a.to node.0, d, {
                                fillOpacity:1
                                ease:f
                            }, e
                            a.to node.1, d, {
                                fillOpacity:0
                                ease:f
                            }, e
                            # увеличиваем svg
                            e = e - 0.5
                            d = 1.0
                            a.to V.s.auth_svg, d, {
                                scale:1.3
                                ease:f
                            }, e
                            # круг => разрыв
                            a.to node.3, d, {
                                mSVG:
                                    shape:node.10
                                    shapeIndex:0
                                ease:f
                            }, e
                            # меняем цвет анимируемых объектов
                            a.to node.2, d, {
                                fill:V.color.80
                                ease:f
                            }, e
                            a.to node.3, d, {
                                fill:V.color.80
                                ease:f
                            }, e
                            # }}}
                            a
                            ## }}}
                        finish: do -> # завершение анимации {{{
                            # таймлайн
                            a = new TimelineLite {
                                paused: true
                                onComplete: !->
                                    @pause!
                                onReverseComplete: !->
                                    @pause!
                            }
                            #
                            # схлопывание
                            #
                            e = 0
                            d = 1
                            f = Back.easeIn
                            # фон svg
                            a.to node.1, d, {
                                fill:V.color.90
                                ease:f
                            }, e
                            # уменьшаем весь элемент
                            a.to V.s.auth_svg, d, {
                                scale:0.9
                                ease:f
                            }, e
                            # разрыв => круг
                            a.to node.3, d, {
                                mSVG:
                                    shape:node.9
                                    shapeIndex:0
                                ease:f
                            }, e
                            # изменяем цвет лого
                            a.to node.2, d, {
                                fill:V.color.90
                                ease:f
                            }, e
                            #
                            # исчезновение
                            #
                            e = e + d
                            d = 2
                            f = Power0.easeNone
                            # убираем лого
                            a.set node.2, {
                                fillOpacity:0
                                onComplete: ->
                                    gs.setNote 12
                                    true
                            }, e
                            # уменьшаем svg в точку
                            a.to V.s.auth_svg, d, {
                                scale:0
                                ease:f
                            }, e
                            # фон svg
                            a.to node.1, d, {
                                fill:V.color.60
                                ease:f
                            }, e
                            # цвет кольца
                            a.to node.3, d, {
                                fill:V.color.60
                                ease:f
                            }, e
                            # исчезновение
                            d = 2.5
                            e = e - 0.5
                            a.to V.view, d, {
                                opacity:0
                                ease:f
                            }, e
                            a
                            ## }}}
                    }
                # }}}
                #
                # определяем обработчики событий
                #
                m_enter = -> # наведение {{{
                    # подготовка
                    return true if dt.clicked
                    dt.moused = true
                    gs.setNote 1
                    a = dt.anim.hover
                    if a.paused! or a.reversed!
                        # анимация
                        a.play!
                    # ok
                    true
                ## }}}
                m_leave = -> # отведение {{{
                    # подготовка
                    return true if dt.clicked
                    dt.moused = false
                    gs.setNote 0
                    a = dt.anim.hover
                    if not a.reversed!
                        # анимация
                        a.reverse!
                    # ok
                    true
                ## }}}
                m_click = -> # клик {{{
                    # проверка
                    if dt.clicked == 1 # передача ключа
                        return true
                    if dt.clicked == 2 # завершение
                        dt.clicked = 0
                        return true
                    return false if dt.clicked
                    # подготовка
                    m_enter! if not dt.moused
                    dt.clicked = 1
                    # поток
                    THREAD [
                        ->
                            # ожидаем hover
                            dt.anim.hover.paused!
                        ->
                            # отключаем пульсацию hover
                            dt.anim.hover.stopit!
                            true
                        ->
                            # заметка
                            gs.setNote 5
                            # запускаем анимацию click
                            dt.anim.click.play!
                            true
                        ->
                            # ожидаем
                            dt.anim.click.paused!
                        ->
                            /* DEBUG */
                            if true
                                # откат!
                                BOUNCE @, 5000, [], !->
                                    # откат click
                                    a = dt.anim.click
                                    b = a.vars.onReverseComplete
                                    # добавляем функцию
                                    a.vars.onReverseComplete = !->
                                        # выполняем оригинал
                                        b!
                                        # откат hover
                                        dt.anim.hover.reverse!
                                        dt.clicked = 0
                                        m_leave! if dt.moused
                                        # восстанавливаем оригинал
                                        a.vars.onReverseComplete = b
                                    ##
                                    dt.anim.click.reverse!
                                # прерываем поток
                                return null
                            /**/
                            true
                            /*
                        ->
                            # запрос ключевого контейнера у пользователя
                            dt.key = 'TODO'
                            true
                        ->
                            # проверка контейнера
                            if not dt.key
                                # отмена
                                dt.clicked = 0
                                dt.anim.click.eventCallback \onReverseComplete, !->
                                    m_leave!
                                dt.anim.click.reverse!
                                return null # прерываем поток
                            # далее
                            true
                        ->
                            # сбрасываем флаг ответа
                            dt.answered = false
                            # анимация ожидания
                            dt.anim.wait.restart!
                            # анимация общего фона (TODO)
                            #dt.anim.0.play!
                            # включаем прогрессбары
                            BOUNCE me, 100, [], !->
                                # заметка
                                gs.setNote 6
                                # состояние ожидания
                                V.pb.eq(0).progressbar {value: false}
                                V.pb.eq(1).progressbar {value: false}
                            # далее
                            true
                        ->
                            # отправляем запрос на сервер (TODO)
                            BOUNCE me, 3000, [], !->
                                # безусловная авторизация
                                dt.answered = true
                                M.authorized = true
                            # далее
                            true
                        ->
                            dt.answered # ожидаем ответ
                        ->
                            # отключаем прогресс
                            V.pb.eq(0).progressbar {value: 0}
                            V.pb.eq(1).progressbar {value: 0}
                            # завершаем анимацию ожидания
                            dt.anim.wait.stop!
                            true
                            */
                        ->
                            # проверка
                            #if not M.authorized
                            if false
                                # в доступе отказано
                                gs.setNote 7
                                #dt.anim.0.reverse 0
                                dt.anim.click.eventCallback \onReverseComplete, !->
                                    m_leave!
                                dt.anim.click.reverse!
                                dt.clicked = 0
                                return null # завершаем поток
                            # доступ получен
                            gs.setNote 8
                            # отключаем излучатель
                            dt.p_count = 0
                            # ускоряем оставшиеся частицы
                            dt.p_acc = dt.p_acc * 10
                            true
                            /*
                        ->
                            # ожидаем завершения
                            dt.anim.wait.stop.ok
                            */
                        ->
                            # сплэш!
                            dt.anim.splash.play!
                            true
                        ->
                            # ожидаем завершения анимации
                            dt.anim.splash.paused!
                        ->
                            # ожидаем клик
                            dt.clicked == 2
                        ->
                            # финальная анимация
                            dt.anim.finish.play!
                            true
                        ->
                            # ожидаем
                            dt.anim.finish.paused!
                        ->
                            # заметка
                            gs.setNote 0
                            # останов функции
                            me.state!
                            # повторная инициализация интерфейса
                            P.init!
                            true
                    ]
                    true
                # }}}
                V.s.auth_btn.mouseenter m_enter
                V.s.auth_btn.mouseleave m_leave
                V.s.auth_btn.click m_click
                #
                # внешние методы
                #
                me.init = -> # подготовка 2D-контекста {{{
                    # проверка
                    if dt.animate
                        # останавливаем текущую анимацию
                        dt.animate = false
                        # повторяем
                        BOUNCE me, 50, [], me.init
                        return true
                    # излучатель
                    # определяем радиус
                    dt.R = dt.radius + V.s.auth_svg.height! / 2
                    # корректируем размер поля
                    a = V.s.canvas.0
                    a.width = V.s.canvas.width!
                    a.height = V.s.canvas.height!
                    # определяем контекст
                    dt.ctx = a.getContext '2d'
                    dt.ctx.strokeStyle = V.color.60
                    # перезагружаем эффекты
                    dt.anim = anim!
                    # запускаем анимацию
                    dt.animate = true
                    me.animate!
                    true
                # }}}
                me.animate = !-> # цикл-функция анимации {{{
                    if dt.animate
                        dt.id = window.requestAnimationFrame me.animate if me.state
                        render!
                # }}}
                me.state = !-> # флаг-функция останова {{{
                    if dt.animate
                        dt.animate = false
                        window.cancelAnimationFrame dt.id if dt.id
                    delete me.state
                    delete me.dt
                # }}}
                me.dt = dt
                #
                # запуск!
                #
                if dt.timeout
                    # пассивное излучение
                    BOUNCE me, (1000 * dt.timeout), [], !-> dt.p_count = 1 if dt.timeout != 0
                me.init!
            # }}}
        # }}}
        color: PROXY { # цвет {{{
            # данные
            Hue: ''
            Saturation: ''
            colors: null    # список используемых цветов
            gradient: {}    # набор градиентов
            root: null      # элемент с CSS-переменными
            ###
            init: -> # {{{
                # singleton!
                # определяем корневой элемент
                return false if @root or (@root = $ \html).length == 0
                # определяем стили
                a = getComputedStyle @root.0
                # определяем параметры цвета
                @Hue = a.getPropertyValue '--col-h' .trim!
                @Saturation = a.getPropertyValue '--col-s' .trim!
                # определяем используемые цвета
                @colors = {}
                for b from 0 to 99
                    # непрозрачный
                    c = '--col'+b
                    @colors[c] = b if a.getPropertyValue c
                    # прозрачный
                    c = c+'a'
                    @colors[c] = -b if a.getPropertyValue c
                # определяем градиенты
                for b from 0 to 99 
                    # нумерация должна быть непрерывной
                    break if not c = a.getPropertyValue '--gr'+b
                    @gradient['gr'+b] = c.trim!
                # устанавливаем цвет
                @set @Hue
            # }}}
            set: (Hue, Saturation = @Saturation) -> # установка цвета {{{
                # проверка
                if not Hue or not Saturation or not @root
                    return false
                # изменяем
                @Hue = Hue
                @Saturation = Saturation
                # определяем текущие значения (для сверки)
                a = window.getComputedStyle @root.0
                # загружаем цвет
                for b,c of @colors when d = a.getPropertyValue b
                    if c >= 0
                        # непрозрачный
                        e = 'hsla('+Hue+', '+Saturation+'%, '+c+'%, 1)'
                        @root.0.style.setProperty b, e if e != d.trim!
                    else
                        # прозрачный
                        c = -c
                        e = 'hsla('+Hue+', '+Saturation+'%, '+c+'%, 0)'
                        @root.0.style.setProperty b, e if e != d.trim!
                # загружаем градиенты
                for b of @gradient
                    c = @[b]
                    @root.0.style.setProperty '--'+b, c
                # возврат
                true
            # }}}
        }, {
            get: (obj, p, prx) -> # цвет по числовому значению Hue {{{
                if typeof p != 'string' or obj[p]
                    # возвращаем как есть
                    a = obj[p]
                else if parseInt p
                    # непрозрачный цвет
                    a = 'hsla('+obj.Hue+','+obj.Saturation+'%,'+p+'%,1)'
                else if 'a' == p.charAt 0
                    # прозрачный
                    p = p.slice 1
                    a = 'hsla('+obj.Hue+','+obj.Saturation+'%,'+p+'%,0)'
                else if obj.gradient[p]
                    # градиент
                    # извлекаем шаблон
                    a = obj.gradient[p]
                    # обработка (определяем цвета)
                    a = a.replace /(--col(\d{2})([a]?))/g, (all, p1, p2, p3, pos, str) ->
                        # подготовка параметра
                        a = if p3 then p3+p2 else p2
                        # рекурсивный вызов
                        if not a = prx[a]
                            a = 'transparent'
                        # возврат
                        a
                else
                    # недопустимый классификатор
                    a = false
                a
            # }}}
        }
        # }}}
        lang: # язык интерфейса {{{
            # общая конфигурация сплита для анимации
            cfg: {}
            title: [ # заголовки {{{

                '' #00
                'Коммунальная Информационная Система' #01
                (t = 'Статистика') -> #02
                    # определяем префикс
                    /*
                    v = V.nav.keys!
                    if v.2
                        t = V.skeleton.getBoneCfg v.2, 'n'
                        a = V.skeleton.getBoneCfg v.1, 'n'
                    else if v.1
                        a = V.skeleton.getBoneCfg v.1, 'n'
                    else
                        a = V.skeleton.getBoneCfg v.0, 'n'
                    # ок
                    a+' :: '+t
                    */
                    return 'rev'

                'Авторизация' #03

            ] # }}}
            note: [ # заметки {{{
                '' #00
                'авторизация' #01
                'активирован тестовый режим' #02
                'подключение к серверу установлено' #03
                'подключение к серверу не установлено' #04
                'загрузка ключевого контейнера' #05
                'аутентификация' #06
                'в доступе отказано' #07
                'доступ получен' #08
                'ссылка' #09
                '' #10
                'сплэш!' #11
                'авторизация завершена' #12
            ] # }}}
            links: [ # ссылки {{{

                ['лаборатория' 'https://vk.com/tvp_lab']

            ] # }}}

        # }}}
        s: PROXY { # ссылки для быстрого доступа к DOM {{{
            clearCache: !-> @cache = {}
            cache: {}
            data:
                main_panel: '#layout_wa_panel_main div.w2ui-panel-content' # главная панель
                canvas: '#view canvas' # канва для рисования
                # авторизация
                auth_svg: '#auth svg' # изображение
                auth_btn: '#authBtn' # кнопа
        }, {
            get: (obj, p, prx) ->
                return obj[p] if obj[p]
                return null if not obj.data[p]
                return obj.cache[p] if obj.cache[p]
                obj.cache[p] = $ obj.data[p]
        }
        # }}}
    }
    /* }}} */
    /* [P]resenter {{{
    */
    P = {
        init: -> # инициализация приложения {{{
            # глобальные зависимости
            deps =
                # браузер
                Proxy: 'прокси-объект'
                getComputedStyle: 'определение стиля'
                requestAnimationFrame: 'метод анимации'
                # подключаемые объекты
                #$: 'jQuery' # существует, если эта функция запущена
                Mustache: 'шаблонизатор'
                TweenMax: 'анимация greensock-js'
                w2ui: 'фреймворк'
            # проверка
            for a,b of deps when not window[a]
                console.log 'отсутствует ['+b+'] '+a
                return false
            # объекты приложения
            if !M or !V or !P
                console.log 'отсутствует объект MVP'
                return false
            # инициализация представления
            if not V.init!
                return false
            # синхронизация
            @_sync!
        # }}}
        #
        # [M] <=> [P] ==> [V]
        #
        # приватный метод
        _sync: (onComplete) -> # синхронизация интерфейса с моделью {{{
            # подготовка
            me = @_sync
            if V.state != 0
                # интерфейс в процессе синхронизации
                # избегаем коллизий (откладываем выполнение)
                BOUNCE @, 100, [onComplete], me
                return true
            # запускаем функцию
            V.state++
            # подготовка
            m = M.nav.keys! # модель
            v = V.nav.keys! # представление
            x = [] # флажки изменений для каждого уровня
            # подготовка навигации
            if M.authorized
                # при пройденной авторизации
                # определяем изменения
                for a,b in m
                    # фиксируем изменение
                    if x[b] = a != v[b]
                        # и распространяем его вверх
                        for c from b + 1 to m.length - 1
                            x[a] = true
                        # дальнейшее выполнение бессмысленно
                        break
                    # сравниваем другие параметры уровня
                    for own a,c of M.nav.data[b]
                        # при наличии хоть одного несоответствия,
                        # устанавливаем флажек и переходим к следующему прерывая цикл
                        break if x[b] = c != V.nav.data[b][a]
                # синхронизация
                # клонируем уровни модели в представление
                for a,b in M.nav.data
                    V.nav.data[b] = CLONE a
            else
                # интерфейс без навигации
                # сброс
                for a in V.nav.data
                    a.id = ''
                # изменения каждый раз
                a = m.length
                x = [true] * a
                m = [''] * a
            # синхронизация завершена
            /* {{{
            lv.2 and t = t ++ [ # {{{
                ->
                    if V.auth
                        V.auth.hide !->
                            gs.setBackground []
                    else if v.2
                        gs.setBackground []
                    V.grid and V.grid.hide !->
                        V.grid.reset! if V.grid.reset
                    # ok
                    true
            ] # }}}
            lv.0 and m.0 and t = t ++ [ # {{{
                ->
                    # аккордеон
                    # генерируем содержимое
                    V.panel.load m.0
                    # определяем активную панель
                    a = if m.1
                        then V.skeleton.index m.1
                        else false
                    # создаем
                    V.panel.accordion V.panel.cfg <<< {active: a}
                    true
            ]
            # }}}
            lv.1 and m.1 and t = t ++ [ # {{{
                ->
                    # ok
                    true
            ]
            # }}}
            lv.2 and m.2 and t = t ++ [ # {{{
                ->
                    # грид
                    # формируем контент
                    V.view.load \grid
                    # создание
                    a = CLONE V.grid.cfg # общая конфигурация
                    b = V.skeleton.getBoneCfg m.2+'g' # частная конфигурация
                    V.grid.w2grid a <<< b
                    # метод удаления
                    V.grid.reset = !->
                        # удаляем грид
                        w2ui.grid.destroy!
                        # удаляем контролы
                        V.gridControls.controlgroup \destroy
                        # удаляем метод
                        delete V.grid.reset
                        # зачищаем контент
                        V.view.load!
                    # контролы грида
                    # создаем
                    V.gridControls.load m.2 + \gc
                    V.gridControls.controlgroup {
                        items:
                            button: \button
                    }
                    # ok
                    true
            ]
            # }}}
            }}} */
            # отстыковка
            V.skeleton.run \detach, x, m, !->
                # стыковка
                V.skeleton.run \attach, x, m, !->
                    # завершено
                    V.state--
                    # завершающая функция
                    onComplete! if onComplete
            # возврат
            true
        # }}}
        # общий (метод не существует если функция выполняется)
        sync: undefined
        #
        # [M] <== [P] <=> [V]
        #
        navigate: (nav, onComplete) -> # навигация {{{
            # проверка
            return false if not @sync
            # полная навигация
            if nav and M.authorized
                # без восстановления текущего уровня
                M.nav.restore = false
                # перезаписываем ключевые значения
                for a,b in nav
                    M.nav.data[b].id = a
                    V.nav.data[b].id = ''
                # теперь запоминаем
                M.nav.restore = true
            # синхронизируем
            @sync !->
                # корректируем размеры
                V.resize 0, !->
                    # корректируем визуальное представление
                    V.refresh!
                    # вызываем завершающую функцию
                    onComplete! if onComplete
            # возврат
            true
        # }}}
        #setNav: (level, key, value, onComplete) -> # переключение навигации
        nav: (level, key, value, onComplete) -> # переключение навигации {{{
            # проверка
            return false if V.state != 0
            # ..
            if key == \id
                # ключевое значение уровня
                M.nav[level] = value
                # конструирование
                @navigate false, onComplete
            else
                # кофигурация уровня
                M.nav[level][key] = value
                V.nav[level][key] = value
                # обновляем интерфейс
                V.resize 0, !->
                    V.refresh onComplete
            # возврат
            true
        # }}}
        switchNavOpt: (level, opt) -> # переключение опции навигации {{{
            return false if P.sync.state or not M.authorized
            a = not M.nav[level][opt]
            M.nav[level][opt] = a
            V.nav[level][opt] = a
            V.resize false
            V.refresh!
            true
        # }}}
    }
    /* }}} */
    ###
    /* debug {{{
    *
    */
    M.authorized = true # отладка
    /**/
    $ \#dbg0 .click !->
        M
        V
        P
        debugger
        /**/
    $ \#dbg1 .click !->
        M.authorized = not M.authorized
        P.init!
        /**/
    $ \#dbg2 .click !->
        #V.GSAP.color MY.randomInt 1, 255
        true
        /**/
    $ \#dbg9 .click !->
        P.init [\m2 \m2v2 \m2v2f1]
        true
        /**/
    /**/
    /* }}} */
    P.init!
#######
$ \document .ready MVPApp


