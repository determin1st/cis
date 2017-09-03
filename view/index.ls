'use strict'

#######
$ \document .ready ->
    ###
    return if not w3ui
    ###
    M = w3ui.PROXY { # model {{{
        # navigation
        nav: [
            {id: 'wa'}
            {id: ''}
            {id: ''}
            {id: ''}
        ]
        sav: [{} {} {}]
        ###
        authorized: true
        ###
        init: -> # {{{
            # initialize navigation save
            a = @nav
            @sav.forEach (save, level) !->
                save[''] = w3ui.CLONE a.slice level + 1
            # done
            true
        # }}}
    }, {
        set: (obj, k, v, prx) -> # {{{
            # set model data
            if typeof k == 'string'
                obj[k] = v
                return true
            # set navigation
            # prepare
            a = obj.nav
            b = obj.sav
            c = a[k]
            d = if k < b.length
                then b[k]
                else null
            # no change
            return true if c.id == v == ''
            # reset
            v = '' if c.id == v
            # backup/restore
            if d
                # save current navigation
                d[c.id] = a.slice k + 1
                # remove higher levels
                a.splice k + 1
                # add higher levels from save
                a = a ++ w3ui.CLONE d[v]
            # change
            c.id = v
            true
        # }}}
        get: (obj, p, prx) -> # {{{
            # check
            return null if typeof p != 'string'
            # get navigation object
            k = parseInt p
            return obj.nav[k].id if not isNaN k
            # return as is
            return obj[p] if p of obj
            return null
        # }}}
    }
    # }}}
    V = # view {{{
        color: w3ui.PROXY { # {{{
            ###
            source: null
            Hue: ''
            Saturation: ''
            colors: null
            gradient: {}
            ###
            init: -> # {{{
                # get source
                a = if @source
                    then @source
                    else $ "html"
                # check
                return false if not a or a.length == 0
                # save
                @source = a
                # get styles
                a = window.getComputedStyle a.0
                # get color parameters
                @Hue = a.getPropertyValue '--col-h' .trim!
                @Saturation = a.getPropertyValue '--col-s' .trim!
                # determine colors
                @colors = {}
                for b from 0 to 99
                    # opaque
                    c = '--col'+b
                    @colors[c] = b if a.getPropertyValue c
                    # transparent
                    c = c+'a'
                    @colors[c] = -b if a.getPropertyValue c
                # determine gradients
                for b from 0 to 99
                    # continual numeration
                    break if not c = a.getPropertyValue '--gr'+b
                    @gradient['gr'+b] = c.trim!
                # select color
                @select @Hue
            # }}}
            select: (Hue, Saturation = @Saturation) -> # {{{
                # check
                if not Hue or not Saturation or not @source
                    return false
                # change
                @Hue = Hue
                @Saturation = Saturation
                # get style
                a = window.getComputedStyle @source.0
                # set style
                # install colors
                for b,c of @colors when d = a.getPropertyValue b
                    if c >= 0
                        # opaque
                        e = 'hsla('+Hue+', '+Saturation+'%, '+c+'%, 1)'
                        @source.0.style.setProperty b, e if e != d.trim!
                    else
                        # transparent
                        c = -c
                        e = 'hsla('+Hue+', '+Saturation+'%, '+c+'%, 0)'
                        @source.0.style.setProperty b, e if e != d.trim!
                # install gradients
                for b of @gradient
                    @source.0.style.setProperty '--'+b, @[b]
                # ok
                true
            # }}}
        }, {
            get: (obj, p, prx) -> # color by Hue {{{
                if typeof p != 'string'
                    # incorrect selector
                    a = null
                else if obj[p]
                    # determined, return as is
                    a = obj[p]
                else if parseInt p
                    # opaque
                    a = 'hsla('+obj.Hue+','+obj.Saturation+'%,'+p+'%,1)'
                else if 'a' == p.charAt 0
                    # transparent
                    p = p.slice 1
                    a = 'hsla('+obj.Hue+','+obj.Saturation+'%,'+p+'%,0)'
                else if obj.gradient[p]
                    # gradient
                    a = obj.gradient[p]
                    # determine its color
                    a = a.replace /(--col(\d{2})([a]?))/g, (all, p1, p2, p3, pos, str) ->
                        # prepare
                        a = if p3 then p3+p2 else p2
                        # recurse
                        a = 'transparent' if not a = prx[a]
                        # done
                        return a
                else
                    # unknown
                    a = ''
                # finish
                return a
            # }}}
        }
        # }}}
        svg: w3ui.PROXY { # {{{
            data: null
            ###
            init: -> # {{{
                # prepare
                @data = {}
                # get template
                if not (a = $ '#t-svg') or a.length == 0
                    return false
                # get nodes
                a = $ a.0.content .find 'div'
                # get contents
                for b from 0 to a.length - 1
                    # store
                    @data[a[b].id] = a[b].innerHTML
                # done
                true
            # }}}
        }, {
            get: (obj, p, prx) -> # {{{
                # check
                if typeof p == 'string'
                    return obj[p] if obj[p]
                    return obj.data[p] if obj.data[p]
                # nothing
                return ''
            # }}}
        }
        # }}}
        root: w3ui 'html'
        ###
        skel: w3ui.PROXY { # interface skeleton {{{
            cfg: # {{{
                # common props
                id: ''              # DOM node identifier
                node: w3ui '#skel'  # DOM node object
                root: w3ui 'html'   # DOM root
                parent: null        # backlink
                level: 0            # node level in skeleton tree
                nav: null           # level navigation
                render: true        # render flag-function
            # }}}
            wa:
                cfg: # {{{
                    init: -> # {{{
                        # prepare
                        # show workarea
                        a = @cfg.node
                        if 0 + a.0.style.opacity < 0.99
                            TweenMax.to a, 2, {
                                opacity: 1
                                ease: Power1.easeOut
                            }
                        # done
                        true
                    # }}}
                # }}}
                modebar: # {{{
                    cfg:
                        # state {{{
                        mode:
                            node: null      # w3ui node
                            icon: ''        # svg icon
                            enabled: false  # state
                            size: null      # captions width in pixels
                            index: -1       # caption index
                        title:
                            node: null
                            size: null
                            index: 0        # not dynamic, external
                        conf:
                            node: null
                            icon: ''
                            enabled: false
                            size: null
                            index: -1
                        # }}}
                        init: -> # {{{
                            # collect DOM nodes
                            @cfg.mode.node  = w3ui '#'+@cfg.id+' .m1'
                            @cfg.title.node = w3ui '#'+@cfg.id+' .box2'
                            @cfg.conf.node  = w3ui '#'+@cfg.id+' .m2'
                            true
                        # }}}
                        refresh: -> # {{{
                            # set captions
                            ['mode' 'conf'].forEach (name) !->
                                # prepare
                                a = @[name]
                                b = @cfg[name]
                                # check disabled
                                b.node.prop 'disabled', not b.enabled
                                if not b.enabled
                                    b.node.html ''
                                    return
                                # select
                                a = if b.index >= 0 and a[b.index]
                                    then a[b.index]
                                    else b.icon
                                # set
                                b.node.html a
                            , @
                            # set title
                            a = @cfg.title
                            a.node.html @title[a.index]
                            # done
                            true
                        # }}}
                        resize: -> # {{{
                            # for each caption
                            # determine font size
                            for a in Object.keys @ when a != 'cfg'
                                # prepare
                                b = @cfg[a]     # state
                                a = @[a]        # data
                                c =
                                    parseInt b.node.style.fontSizeMin
                                    parseInt b.node.style.fontSizeMax
                                # correct
                                c.0 = 0  if isNaN c.0
                                c.1 = 64 if isNaN c.1
                                # check
                                continue if not a
                                # define
                                b.size = a.map (text) ->
                                    # skip empty
                                    return 0 if not text
                                    # determine maximal value
                                    a = b.node.textMeasureFont text
                                    # check and correct
                                    a = c.0 if a < c.0
                                    a = c.1 if a > c.1
                                    # done
                                    return a
                            # for dynamic captions
                            # determine index and set font size
                            ['mode' 'conf'].forEach (name) !->
                                # prepare
                                a = @cfg[name]
                                b = @[name]
                                # check
                                if not b
                                    a.index = -1
                                    return
                                # determine index
                                # with maximal font size
                                c = Math.max.apply null, a.size
                                a.index = a.size.findIndex (val) ->
                                    val - c < 0.0001
                                # set font size
                                b = a.size[a.index]
                                a.node.style.fontSize = b+'px'
                            , @
                            # set font size for title
                            a = @cfg.title
                            b = a.size[a.index]
                            a.node.style.fontSize = b+'px'
                            # determine global font size
                            @cfg.root.style.f1SizeMax = a.size.0
                            # done
                            true
                        # }}}
                    ###
                    mode: null
                    conf:
                        'Настройки'
                        'Настр'
                        ''
                    title:
                        'Главное меню'
                        ''
                        'Конфигурация'
                # }}}
                view: # {{{
                    cfg: 
                        render: true
                    ###
                    menu: # {{{
                        cfg:
                            init: -> # {{{
                                true
                            # }}}
                        list:
                            {
                                id: 'card'
                                name: 'Картотека'
                            }
                            {
                                id: 'm2'
                                name: '2'
                            }
                            {
                                id: 'm3'
                                name: '3'
                            }
                            {
                                id: 'm4'
                                name: '4'
                            }
                            {
                                id: 'm5'
                                name: '5'
                            }
                            {
                                id: 'm6'
                                name: '6'
                            }
                        card:
                            'Картотека'
                            'Карта'
                            ''
                    # }}}
                # }}}
                console: # {{{
                    cfg:
                        empty: true
                    ###
                    log: # {{{
                        error:
                            'Ошибка'
                            'в доступе отказано'
                        warning:
                            'Предупреждение'
                        info:
                            'Статус'
                            'активирован тестовый режим'
                            'подключение к серверу установлено'
                            'подключение к серверу не установлено'
                            'загрузка ключевого контейнера'
                            'аутентификация'
                            'авторизация'
                            'доступ разрешен'
                            'авторизация завершена'
                    # }}}
                # }}}
        }, {
            get: (obj, id, prx) -> # {{{
                # check root
                return obj if not id
                # check root child
                return obj[id] if obj[id]
                # check this node is a leaf
                return null if not obj.cfg
                # search in branch
                # initiate stack
                a = [obj]
                # iterate
                while a.length
                    # extact node
                    b = a.pop!
                    # check sub-branches
                    for own k,v of b when k != 'cfg' and v and v.cfg
                        # found
                        return v[id] if v[id]
                        # add to stack
                        a.push v
                # not found
                return null
            # }}}
        }
        # }}}
        ###
        init: (id = '', parent = null, level = 0) -> # {{{
            # get node
            if not a = @skel[id]
                console.log 'getting of "'+id+'" failed'
                return false
            # initialize
            if id
                a.cfg.id     = id
                a.cfg.parent = parent
                a.cfg.root   = parent.cfg.root if parent
                a.cfg.level  = level
                a.cfg.render = w3ui.PARTIAL @, @render, id if a.cfg.render
            # recurse to children
            for b,c of a when b != 'cfg' and c and c.cfg
                return false if not @init b, a, level + 1
            # completed
            true
        # }}}
        walk: (id, direction, func) -> # {{{
            # prepare
            # get start node
            debugger
            return false if not a = @skel[id]
            # create walk array
            walk = []
            b = [a]
            while b.length
                # add step
                walk.push b
                # collect children from last step
                b = b.map (node) ->
                    # collect
                    c = []
                    for a,b of node when a != 'cfg' and b and b.cfg
                        c.push b
                    # done
                    c
                # merge
                b = b.reduce (a, b) !->
                    a = a ++ b
                , []
            # now we have two-dimensional walk array,
            # lets flatten it
            walk = walk.reduce (a, level) !->
                a = a ++ b
            , []
            # check direction
            walk.reverse! if not direction
            # walk
            # check function
            if typeof func == 'string'
                # internal
                a = walk.every (node) ->
                    if node.cfg[func] and node.cfg.node
                        then node.cfg[func].apply node
                        else true
            else
                # external
                a = walk.every (node) -> func.apply node
            # done
            a
        # }}}
        render: (id) -> # {{{
            # prepare
            # get templates
            if not (a = $ 'template') or a.length == 0
                return true
            # select template
            a = $ a.0.content .find '#t-'+id
            a = a.0.innerHTML
            # select data
            b = @[id]
            # construct HTML
            a = Mustache.render a, b
            # inject
            @cfg.node.html a
            # add DOM node
            b.cfg.node = w3ui '#'+id if b.cfg
            # done
            true
        # }}}
        # TODO
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
                    w3ui.THREAD @, [
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
    # }}}
    P = # presenter {{{
        init: -> # {{{
            # initialize
            if not M.init! or not V.init!
                console.log 'init() failed'
                return false
            # update
            if not P.update M.0
                console.log 'update() failed'
                return false
            # attach resize handler
            $ window .on 'resize', !-> P.resize!
            # done
            true
        # }}}
        resize: !-> # {{{
            # prepare
            me = @resizeWindow
            # activate debounce protection (delay)
            if me.timer
                # reset timer
                window.clearTimeout me.timer
                # set timer
                f = w3ui.PARTIAL @, me
                me.timer = window.setTimeout f, 250
                return
            # resize
            ['resize' 'refresh'].every (method) ->
                V.walk M.0, true, method
        # }}}
        update: (id) -> # {{{
            # run update sequence
            ['render' 'init' 'resize' 'refresh'].every (method) ->
                V.walk id, true, method
        # }}}
    # }}}
    ###
    P.init! if M and V and P
#######

