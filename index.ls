'use strict'

w3ui and w3ui.app {
    M: # {{{
        #navDefault: ['wa' 'view' 'menu']
        navDefault: ['w3demo' 'view' 'widget' 'accordion']
    # }}}
    V: # {{{
        ui:
            cfg: # {{{
                id: ''              # node identifier (key)
                node: null          # DOM node (w3ui wrapper)
                parent: null        # backlink
                context: null       # primary context (for adjacent nodes)
                data: {}            # data storage
                level: 0            # node level in interface tree
                nav: null           # model navigation
                el: null            # element selector
                render: true        # flag-function
            # }}}
            wa:
                cfg: # {{{
                    fontSizeMin: 0
                    fontSizeMax: 0
                    init: ->
                        @cfg.fontSizeMin = parseInt @cfg.node.style.fSizeMin
                        @cfg.fontSizeMax = parseInt @cfg.node.style.fSizeMax
                        true
                # }}}
                view: # {{{
                    cfg: # {{{
                        render: true
                        turn: # {{{
                            on:
                                {
                                    to:
                                        className: '+=color'
                                        opacity: 0
                                        scale: 0.6
                                }
                                {
                                    duration: 0.2
                                    to:
                                        opacity: 0.5
                                }
                                {
                                    duration: 0.6
                                    to:
                                        opacity: 1
                                        scale: 1
                                }
                                {
                                    position: '-=0.1'
                                    duration: 0.3
                                    to:
                                        className: '-=color'
                                }
                            off:
                                {
                                    duration: 0.2
                                    to:
                                        className: '+=color'
                                        scale: 0.9
                                }
                                {
                                    duration: 0.8
                                    to:
                                        scale: 1
                                        opacity: 0
                                }
                        # }}}
                    # }}}
                    menu: # {{{
                        cfg:
                            render: true
                            init: -> # {{{
                                # prepare
                                c = @cfg
                                d = @cfg.data
                                if not d.menu
                                    d.menu = c.node.query '.box'
                                    d.time = c.show.1.duration
                                # initialize model
                                while (a = c.nav.current) == undefined
                                    c.nav.current = 0
                                while not (b = c.nav.currentItem)
                                    c.nav.currentItem = @data.map -> 0
                                # set style
                                d.menu[a].style.visibility = 'visible'
                                # done
                                true
                            # }}}
                            finit: -> # {{{
                                # prepare
                                w3ui.clearObject @cfg.data
                                # done
                                true
                            # }}}
                            refresh: -> # {{{
                                # prepare
                                cfg  = @cfg
                                data = @cfg.data
                                if not data.box
                                    # nodes
                                    a = cfg.nav.current
                                    data.box = data.menu[a]
                                    data.btn = data.box.query '.button'
                                    # numbers & ids
                                    for b from 0 to data.btn.length - 1
                                        data.btn[b].dataset.num = b
                                        data.btn[b].dataset.id = @data[a].list[b].id
                                    # style
                                    a = cfg.nav.currentItem[a]
                                    data.btn[a].class.add 'active'
                                # initialize slide effect
                                # {{{
                                if not data.slide
                                    # prepare
                                    # determine indexes
                                    a = cfg.nav.current or 0
                                    b = data.menu.length - 1
                                    c =
                                        if a > 0 then a - 1 else b # left
                                        if a < b then a + 1 else 0 # right
                                    # define transition items
                                    a =
                                        [data.menu[a].node, data.menu[c.0].node]
                                        [data.menu[a].node, data.menu[c.1].node]
                                    # define transition parameters
                                    c =
                                        ['0%' '100%' '-100%' '0%']
                                        ['0%' '-100%' '100%' '0%']
                                    # create effect
                                    data.slide = a.map (a, index) ->
                                        # create timeline
                                        b = new TimelineLite {
                                            paused: true
                                            data:
                                                complete: !->
                                                    # invalidate
                                                    delete data.slide
                                        }
                                        # step 0
                                        # initital state
                                        b.set a, {
                                            transformOrigin: '0% 50%'
                                            visibility: 'visible'
                                        }
                                        # step 1
                                        # move transition
                                        b.addLabel 's1'
                                        b.fromTo a.0, data.time, {
                                            x: c[index].0
                                        }, {
                                            x: c[index].1
                                        }, 's1'
                                        b.fromTo a.1, data.time, {
                                            x: c[index].2
                                        }, {
                                            x: c[index].3
                                        }, 's1'
                                        # finish
                                        b.set a.0, {
                                            visibility: 'hidden'
                                        }
                                        b.set a.1, {
                                            visibility: 'visible'
                                        }
                                        # done
                                        b
                                # }}}
                                # initialize menu drag/swipe effect
                                # {{{
                                if not data.drag
                                    # get both slide effects
                                    a = cfg.el.console.cfg.data.slide
                                    b = data.slide
                                    # create timelines
                                    c =
                                        new TimelineLite {paused: true, ease: Power3.easeInOut}
                                        new TimelineLite {paused: true, ease: Power3.easeInOut}
                                    # define startup routine
                                    d = !->
                                        a = 'drag'
                                        b = not cfg.node.class.has a
                                        cfg.node.class.toggle a, b
                                    # define complete routine
                                    e = (index) -> !->
                                        cfg.node.class.remove 'drag'
                                        a[index].data.complete!
                                        b[index].data.complete!
                                        delete data.box
                                        delete data.drag
                                    # add tweens
                                    c.0.add d
                                    c.0.add a.0.play!, 0
                                    c.0.add b.0.play!, 0
                                    c.0.add e 0
                                    c.1.add d
                                    c.1.add a.1.play!, 0
                                    c.1.add b.1.play!, 0
                                    c.1.add e 1
                                    # done
                                    data.drag = c
                                # }}}
                                # done
                                true
                            # }}}
                            show: # {{{
                                {
                                    to:
                                        backgroundColor: 'transparent'
                                        scale: 0
                                }
                                {
                                    duration: 0.8
                                    to:
                                        scale: 1
                                        clearProps: 'backgroundColor'
                                        ease: Back.easeOut
                                }
                            # }}}
                            hide: # {{{
                                {
                                    duration: 0.8
                                    to:
                                        scale: 0
                                        ease: Power3.easeIn
                                }
                                ...
                            # }}}
                            attach: # {{{
                                click:
                                    el: '.button'
                                pointerover:
                                    el: '.button'
                                pointerdown:
                                    el: ''
                                pointermove:
                                    el: ''
                                pointerup:
                                    el: ''
                                keydown:
                                    keys: ['ArrowUp' 'ArrowDown']
                            # }}}
                        title: 'Главное меню'
                        config: true
                        data:
                            {
                                id: 'card'
                                name: 'Картотека'
                                list:
                                    {
                                        id: 'address'
                                        name: 'Адреса'
                                    }
                                    {
                                        id: 'counterparty'
                                        name: 'Контрагенты'
                                    }
                            }
                            {
                                id: 'income'
                                name: 'Входящие'
                                list:
                                    {
                                        id: 'accrual'
                                        name: 'Начисления'
                                    }
                                    {
                                        id: 'payment'
                                        name: 'Оплата'
                                    }
                                    {
                                        id: 'storno'
                                        name: 'Сторно'
                                    }
                            }
                            {
                                id: 'outcome'
                                name: 'Исходящие'
                                list:
                                    {
                                        id: 'calc'
                                        name: 'Расчеты'
                                    }
                                    {
                                        id: 'document'
                                        name: 'Отчеты'
                                    }
                            }
                    # }}}
                    address: # {{{
                        cfg:
                            refresh: -> # {{{
                                # prepare
                                # ..
                                # done
                                true
                            # }}}
                            show: # {{{
                                {
                                    duration: 0
                                    to:
                                        scale: 0
                                }
                                {
                                    duration: 0.8
                                    to:
                                        scale: 1
                                        ease: Back.easeOut
                                }
                            # }}}
                            hide: # {{{
                                {
                                    duration: 0.8
                                    to:
                                        scale: 0
                                        ease: Back.easeIn
                                }
                                ...
                            # }}}
                        title: 'Адреса'
                        config: true
                        tab:
                            # {{{
                            {
                                id: 'a0'
                                name: 'квартира'
                            }
                            {
                                id: 'a1'
                                name: 'дом'
                            }
                            {
                                id: 'a2'
                                name: 'улица'
                            }
                            {
                                id: 'a3'
                                name: 'район'
                            }
                            {
                                id: 'a4'
                                name: 'город'
                            }
                            # }}}
                    # }}}
                    payment: # {{{
                        cfg:
                            refresh: -> # {{{
                                # prepare
                                # ..
                                # done
                                true
                            # }}}
                        title: 'Оплата'
                    # }}}
                    config: # {{{
                        cfg:
                            init: -> # {{{
                                #@current = @cfg.nav.current
                                true
                            # }}}
                            refresh: -> # {{{
                                true
                            # }}}
                        title: 'Конфигурация'
                        current: ->
                            return @cfg.nav.current
                    # }}}
                # }}}
                header: # {{{
                    cfg:
                        render: false
                        init: -> # {{{
                            # prepare
                            # collect DOM nodes
                            cfg = @cfg
                            dat = cfg.data
                            ctx = cfg.context
                            id  = if ctx
                                then ctx.cfg.id
                                else ''
                            if not dat.title
                                dat.title  = cfg.node.query '.title'
                                dat.mode   = cfg.node.query '.mode .button'
                                dat.config = cfg.node.query '.config .button'
                            # initialize container class
                            cfg.node.class.clear 'on'
                            cfg.node.class.add id
                            # initialize elements
                            # {{{
                            # title
                            dat.title.$text = if ctx and ctx.title
                                then ctx.title
                                else ''
                            # mode
                            a = if id == 'menu'
                                then 'return'
                                else 'menu'
                            b = dat.mode
                            ##
                            b.$text = @mode[a]
                            b.$icon = cfg.template.querySelector '#'+a .innerHTML
                            b.$anim.kill! if b.$anim
                            b.prop.dataId = 'mode'
                            # config
                            a = if id == 'config'
                                then 'close'
                                else 'config'
                            b = dat.config
                            b.$text = @config[a]
                            b.$icon = cfg.template.querySelector '#'+a .innerHTML
                            b.$anim.kill! if b.$anim
                            b.prop.dataId = 'config'
                            # }}}
                            # initialize animations
                            # {{{
                            # determine disabled
                            a =
                                (id == 'config')
                                (id != 'config' and (!ctx or !ctx.config))
                            # buttons
                            b =
                                dat.mode.node
                                dat.config.node
                            # disabled buttons
                            c = []
                            c.push b.0 if a.0
                            c.push b.1 if a.1
                            # enabled buttons
                            d = []
                            d.push b.0 if not a.0
                            d.push b.1 if not a.1
                            # set
                            a = cfg.show.0.group
                            a.0.node = dat.title.node
                            a.2.node = c
                            a.3.node = b
                            cfg.show.4.node = dat.title.node
                            cfg.show.5.node = b
                            ##
                            cfg.hide.1.node = b
                            cfg.hide.2.node = dat.title.node
                            ##
                            cfg.turn.1.node = dat.title.node
                            cfg.turn.2.node = b
                            cfg.turn.2.group.2.node = d
                            ##
                            dat.resizeAnim = w3ui.GSAP.queue cfg.node, [
                                cfg.hide.1
                                cfg.show.5
                            ]
                            # }}}
                            # done
                            true
                        # }}}
                        resize: (noAnimation = false) -> # {{{
                            # prepare
                            cfg = @cfg
                            dat = @cfg.data
                            # determine workarea font size
                            # {{{
                            a = dat.title.box.fontSize dat.title.$text
                            c = cfg.el.wa.cfg
                            b =
                                c.fontSizeMin
                                c.fontSizeMax
                            a = 0 if a < b.0
                            a = b.1 if a > b.1
                            # update css variable
                            c.node.style.fSize0 = a+'px'
                            # }}}
                            # determine buttons state
                            # {{{
                            # check animation in progress
                            a = dat.resizeAnim.isActive!
                            return true if a
                            # check if icon must be used
                            dat.useIcon = [dat.mode, dat.config].some (a) ->
                                if a.$text and not a.class.has 'disabled'
                                    # get text width
                                    b = a.box.textMetrics a.$text .width
                                    # compare with container width
                                    if a.box.innerWidth < b
                                        # use icon!
                                        return true
                                # continue
                                return false
                            # }}}
                            # check
                            b = dat.mode.class.has 'icon'
                            if noAnimation or not (dat.useIcon xor b)
                                return true
                            # change
                            return dat.resizeAnim.play 0
                        # }}}
                        show: # {{{
                            # 0. PREPARE TITLE and BUTTONS
                            {
                                group:
                                    # 0. TITLE HIDE
                                    {
                                        node: null
                                        to:
                                            opacity: 0
                                            scale: 0
                                    }
                                    # 1. TITLE SET
                                    !->
                                        a = @cfg.data.title
                                        a.html = a.$text
                                    # 2. BUTTONS DISABLE
                                    {
                                        node: null
                                        to:
                                            className: '+=disabled'
                                    }
                                    # 3. BUTTONS UN-HOVER and HIDE
                                    {
                                        node: null
                                        to:
                                            className: '-=hovered'
                                            scale: 0
                                    }
                            }
                            # 1. SHOW CONTAINER
                            {
                                position: 'beg'
                                duration: 0.4
                                to:
                                    className: 'on'
                                    opacity: 1
                                    ease: Power3.easeOut
                            }
                            # 2. RESIZE
                            !-> @cfg.resize.call @, true
                            # 3. LABEL
                            'show'
                            # 4. SHOW TITLE
                            {
                                position: 'show'
                                node: null
                                duration: 0.6
                                to:
                                    opacity: 1
                                    scale: 1
                                    ease: Back.easeOut
                            }
                            # 5. SHOW BUTTONS
                            {
                                position: 'show'
                                node: null
                                group:
                                    # SET
                                    !->
                                        # prepare
                                        a = @cfg.data
                                        b = if a.useIcon
                                            then '$icon'
                                            else '$text'
                                        # set content
                                        a.mode.html   = a.mode[b]
                                        a.config.html = a.config[b]
                                        # get icons
                                        a.mode.$svg   = a.mode.query 'svg'
                                        a.config.$svg = a.config.query 'svg'
                                        # set style
                                        a.mode.class.toggle 'icon', a.useIcon
                                        a.config.class.toggle 'icon', a.useIcon
                                    # SHOW
                                    {
                                        duration: 0.4
                                        to:
                                            scale: 1
                                            ease: Back.easeOut
                                    }
                            }
                        # }}}
                        hide: # {{{
                            # 0. LABEL
                            'beg'
                            # 1. HIDE BUTTONS
                            {
                                position: 'beg'
                                duration: 0.4
                                node: null
                                to:
                                    scale: 0
                                    ease: Power3.easeIn
                            }
                            # 2. HIDE TITLE
                            {
                                position: 'beg'
                                duration: 0.4
                                node: null
                                to:
                                    scale: 0
                                    opacity: 0
                                    ease: Power3.easeIn
                            }
                            # 3. HIDE CONTAINER
                            {
                                duration: 0.4
                                to:
                                    className: ''
                                    ease: Power3.easeIn
                            }
                        # }}}
                        turn: # {{{
                            # 0. LABEL
                            'beg'
                            # 1. CHANGE TITLE
                            {
                                position: 'beg'
                                node: null
                                group:
                                    # 0. HIDE
                                    {
                                        duration: 0.4
                                        to:
                                            opacity: 0
                                            scale: 0.6
                                            ease: Power2.easeIn
                                    }
                                    # 1. SET
                                    !->
                                        a = @cfg.data
                                        a.title.html = a.title.$text
                                    # 2. SHOW
                                    {
                                        duration: 0.4
                                        to:
                                            opacity: 1
                                            scale: 1
                                            ease: Back.easeOut
                                    }
                            }
                            # 2. CHANGE BUTTONS
                            {
                                position: 'beg'
                                node: null
                                group:
                                    # 0. HIDE
                                    {
                                        duration: 0.2
                                        to:
                                            className: '-=hovered'
                                            opacity: 0
                                            scale: 0.8
                                            ease: Power2.easeIn
                                    }
                                    # 1. SET
                                    !->
                                        # prepare
                                        d = @cfg.data
                                        a = d.mode
                                        b = d.config
                                        c = if d.useIcon
                                            then '$icon'
                                            else '$text'
                                        # set content
                                        a.html = a[c]
                                        b.html = b[c]
                                        # get icons
                                        a.$svg = a.query 'svg'
                                        b.$svg = b.query 'svg'
                                        # reset style
                                        a.class.toggle 'icon', d.useIcon
                                        b.class.toggle 'icon', d.useIcon
                                    # 2. SHOW
                                    {
                                        duration: 0.4
                                        node: null
                                        to:
                                            opacity: 1
                                            scale: 1
                                            ease: Power2.easeOut
                                    }
                            }
                        # }}}
                        attach: # {{{
                            pointerover:
                                {
                                    el: '.button'
                                    id: ''
                                }
                            pointerout:
                                {
                                    el: '.button'
                                    id: ''
                                }
                            click:
                                {
                                    el: '.mode .button'
                                    id: 'mode'
                                }
                                {
                                    el: '.config .button'
                                    id: 'config'
                                }
                        # }}}
                    mode:
                        return: 'возврат'
                        menu: 'меню'
                    config:
                        close: 'закрыть'
                        config: 'настройки'
                # }}}
                console: # {{{
                    cfg: # {{{
                        render: true
                        attach: true
                        init: -> # {{{
                            # prepare
                            cfg = @cfg
                            id  = cfg.nav.id
                            # set container class
                            cfg.node.class.clear 'on'
                            cfg.node.class.add id
                            true
                        # }}}
                        resize: -> # {{{
                            # invalidate data
                            w3ui.clearObject @cfg.data
                            # delegate
                            @cfg.refresh.call @
                        # }}}
                        refresh: -> # {{{
                            # prepare
                            a = @cfg.nav.id
                            b = @[a]
                            return true if not b or not b.refresh
                            # delegate
                            b.refresh.call @
                        # }}}
                        show: # {{{
                            {
                                duration: 0.8
                                to:
                                    className: '+=on'
                                    opacity: 1
                                    ease: Power3.easeOut
                            }
                            ...
                        # }}}
                        hide: # {{{
                            {
                                duration: 0.6
                                to:
                                    className: ''
                                    opacity: 0
                                    ease: Power3.easeIn
                            }
                            ...
                        # }}}
                        turn: # {{{
                            off:
                                {
                                    duration: 0.4
                                    to:
                                        opacity: 0
                                }
                                {
                                    to:
                                        display: 'none'
                                }
                            on:
                                {
                                    position: 0.4
                                    label: 'beg'
                                }
                                {
                                    position: 'beg'
                                    to:
                                        opacity: 0
                                        scale: 0.5
                                        clearProps: 'display'
                                }
                                {
                                    position: 'beg'
                                    duration: 0.4
                                    to:
                                        opacity: 1
                                        scale: 1
                                }
                        # }}}
                    # }}}
                    menu:
                        attach: # {{{
                            pointerover:
                                {
                                    el: '.button.left'
                                    id: 'left'
                                }
                                {
                                    el: '.button.right'
                                    id: 'right'
                                }
                            pointerout:
                                {
                                    el: '.button.left'
                                    id: 'left'
                                }
                                {
                                    el: '.button.right'
                                    id: 'right'
                                }
                            click:
                                {
                                    el: '.button.left'
                                    id: 'left'
                                    delayed: true
                                }
                                {
                                    el: '.button.right'
                                    id: 'right'
                                    delayed: true
                                }
                            keydown:
                                keys: ['ArrowLeft' 'ArrowRight' 'Enter']
                                delayed: true
                        # }}}
                        render: -> # {{{
                            # prepare
                            ctx = @cfg.context
                            a = ctx.data
                            b = ctx.cfg.nav.current or 0
                            c = a.length - 1
                            d = @cfg.data
                            # generate template data
                            d.list = a.map (a) ->
                                {
                                    id: a.id
                                    name: a.name
                                }
                            d.current = a[b].name
                            d.prev = if b
                                then a[b - 1].name
                                else a[* - 1].name
                            d.next = if b == c
                                then a.0.name
                                else a[b + 1].name
                            # done
                            return d
                        # }}}
                        refresh: -> # {{{
                            # TODO!
                            # initialize data
                            data = @cfg.data
                            if not data.node
                                data.node = @cfg.node.query '.menu'
                                data.time = @cfg.show.0.duration
                            if not data.box
                                data.box = data.node.query '.item'
                                data.btn = data.node.query '.button'
                            # initialize hover effect
                            # {{{
                            if not data.hover
                                # prepare
                                a = data.box
                                b = data.btn
                                c =
                                    [a.1.node, b.1.node, a.2.node, b.2.node]
                                    [a.3.node, b.3.node, a.2.node, b.2.node]
                                # for left and right nodes
                                data.hover = c.map (c) ->
                                    # create timeline
                                    d = new TimelineLite {
                                        paused: true
                                        ease: Power2.easeOut
                                    }
                                    # un-hover at start
                                    d.add let a = a, b = b
                                        !->
                                            a.class.remove 'hover'
                                            b.class.remove 'hover'
                                    # hover
                                    d.to c, data.time, {
                                        className: '+=hover'
                                    }
                                    # done
                                    d
                            # }}}
                            # initialize slide effect
                            # {{{
                            if not data.slide
                                # prepare
                                main = @cfg.context
                                # determine current
                                a = main.cfg.nav.current or 0
                                b = main.data.length - 1
                                # determine new
                                c =
                                    # from left
                                    if a > 1
                                        then a - 2
                                        else a - 1 + b
                                    # from right
                                    if a + 2 <= b
                                        then a + 2
                                        else a + 1 - b
                                # set captions
                                data.btn.0.html = main.data[c.0].name
                                data.btn.4.html = main.data[c.1].name
                                # clone border nodes
                                a =
                                    data.box.0.clone!
                                    data.box.4.clone!
                                #b =
                                #    w3ui '.button', a.0, true
                                #    w3ui '.button', a.1, true
                                # prepare list
                                #a =
                                #    [a.0, b.0.0]
                                #    [a.1, b.1.0]
                                # create effect
                                data.slide = a.map (newBox, index) ->
                                    # create timeline
                                    a = new TimelineMax {
                                        paused: true
                                        data:
                                            complete: !->
                                                # cleanup inline styles
                                                data.box.prop.style = null
                                                data.btn.prop.style = null
                                                # change DOM
                                                a = data.node.child
                                                if index
                                                    # +right -left
                                                    a.add newBox
                                                    a.remove data.box.0
                                                else
                                                    # -right +left
                                                    a.insert newBox
                                                    a.remove data.box.4
                                                # invalidate current data
                                                delete data.box
                                                delete data.hover
                                                delete data.slide
                                    }
                                    # define transition classes
                                    if index
                                        b =
                                            ['+=hidden' '-=active' '+=active' '-=hidden']
                                            ['+=hidden' 'button left' 'button center' '-=hidden']
                                    else
                                        b =
                                            ['-=hidden' '+=active' '-=active' '+=hidden']
                                            ['-=hidden' 'button center' 'button right' '+=hidden']
                                    # add tweens
                                    # container
                                    a.to data.box[index + 0].node, data.time, {
                                        className: b.0.0
                                    }, 0
                                    a.to data.box[index + 1].node, data.time, {
                                        className: b.0.1
                                    }, 0
                                    a.to data.box[index + 2].node, data.time, {
                                        className: b.0.2
                                    }, 0
                                    a.to data.box[index + 3].node, data.time, {
                                        className: b.0.3
                                    }, 0
                                    # button
                                    a.to data.btn[index + 0].node, data.time, {
                                        className: b.1.0
                                    }, 0
                                    a.to data.btn[index + 1].node, data.time, {
                                        className: b.1.1
                                    }, 0
                                    a.to data.btn[index + 2].node, data.time, {
                                        className: b.1.2
                                    }, 0
                                    a.to data.btn[index + 3].node, data.time, {
                                        className: b.1.3
                                    }, 0
                                    # done
                                    a
                            # }}}
                            # done
                            true
                        # }}}
                    address:
                        render: -> # {{{
                            return {}
                        # }}}
                    payment:
                        render: -> # {{{
                            return {}
                        # }}}
                # }}}
            w3demo:
                cfg: # {{{
                    empty: true
                # }}}
                view: # {{{
                    cfg: # {{{
                        render: true
                    # }}}
                    intro: # {{{
                        cfg:
                            empty: true
                        data:
                            {
                                title: 'Документация w3ui'
                                text: 'bla bla bla'
                            }
                            ...
                    # }}}
                    widget: # {{{
                        cfg:
                            init: -> # {{{
                                # create widget
                                a = @cfg.nav.id
                                b = w3ui[a] @cfg.node, @[a].options
                                # store
                                @cfg.data.widget = b
                                true
                            # }}}
                        accordion: # {{{
                            title: 'аккордеон'
                            options:
                                panels: [
                                    {
                                        name: 'test1'
                                        val: 'text1'
                                    }
                                    {
                                        name: 'test2'
                                        val: [
                                            {
                                                name: 'test2-1'
                                                val: 'text2-1'
                                            }
                                            {
                                                name: 'test2-2'
                                                val: 'text2-2'
                                            }
                                        ]
                                    }
                                    {
                                        name: 'test3'
                                        val: 'text3'
                                    }
                                ]
                        # }}}
                        slider: # {{{
                            title: 'слайдер'
                        # }}}
                    # }}}
                # }}}
                sidebar: # {{{
                    cfg:
                        render: false
                        init: -> # {{{
                            true
                        # }}}
                # }}}
    # }}}
    P: # {{{
        react: (M, V, P, event) ->
            # prepare
            cfg = @cfg
            nav = @cfg.nav
            dat = event.data
            # process
            switch cfg.id
            | 'header' =>
                # {{{
                # prepare
                a = event.currentTarget.dataset.id
                # kill hover animation
                b = cfg.data[a]
                b.$anim.kill! if b.$anim
                # proceed
                switch event.type
                | 'pointerover' =>
                    # hover
                    # {{{
                    if cfg.data.useIcon
                        # icon
                        b.$svg.class.add 'hovered'
                    else
                        # button
                        b.$anim = TweenLite.to b.node, 0.6, {
                            className: '+=hovered'
                            ease: Power3.easeOut
                        }
                    # }}}
                | 'pointerout' =>
                    # unhover
                    # {{{
                    if cfg.data.useIcon
                        # icon
                        b.$svg.class.remove 'hovered'
                    else
                        # button
                        TweenLite.to b.node, 0.4, {
                            className: '-=hovered'
                            ease: Power3.easeIn
                        }
                    # }}}
                | 'click' =>
                    # navigation
                    # {{{
                    b = nav.id
                    if a == 'mode' and b == 'menu'
                        # close main menu of workareas,
                        # return to selector
                        # ..
                        break
                    else if a == 'config'
                        if b == 'config'
                            # close configuration,
                            # return to workarea
                            M[cfg.level] = M.nav[cfg.level + 1].current
                        else
                            # open configuration,
                            # close workarea
                            M[cfg.level] = 'config'
                            M.nav[cfg.level + 1].current = b
                    else
                        # return to main menu,
                        # close workarea
                        M[cfg.level] = 'menu'
                    # go
                    P.update!
                    # }}}
                # }}}
            | 'menu' =>
                # {{{
                # define menu change routine
                # {{{
                not dat.change and dat.change = (active) !~>
                    # determine menu index
                    a = nav.current or 0
                    b = @data.length - 1
                    if active
                        a = if a > 0 then a - 1 else b
                    else
                        a = if a < b then a + 1 else 0
                    # change
                    nav.current = a
                # }}}
                # react
                switch event.type
                | 'pointerdown' =>
                    # drag start
                    # {{{
                    # check pointer position
                    a = document.elementFromPoint event.pageX, event.pageY
                    break if a.className == 'button'
                    # prepare
                    event.stopPropagation!
                    # set drag parameters
                    dat.swipe = event.pointerType != 'mouse'
                    dat.size = 0.5 * cfg.node.box.innerWidth
                    dat.x = event.pageX
                    dat.active = false
                    dat.drag = V.el.menu.cfg.data.drag
                    # }}}
                | 'pointermove' =>
                    # drag
                    # {{{
                    # check if started
                    break if not dat.drag
                    # prepare
                    event.stopPropagation!
                    # determine drag distance
                    # and active timeline
                    if (a = event.pageX - dat.x) < 0
                        b = [0 1]
                    else
                        b = [1 0]
                    # check
                    if (a = Math.abs a) < 0.1
                        # cancel drag
                        break if not dat.swipe
                        # cancel swipe
                        delete dat.drag
                        break
                    # select timelines
                    c = b.map (index) -> dat.drag[index]
                    # determine position
                    a = a / dat.size
                    a = 0.99 if a > 0.99
                    # swipe!
                    if dat.swipe
                        # change model
                        dat.change b.0
                        delete dat.drag
                        # add refresher and play
                        c.1.add P.refresh
                        return c.1.play!
                    # drag!
                    # check active
                    d = not dat.active or dat.active.0 != b.0
                    e = d or (Math.abs a - c.1.progress!) > 0.001
                    # animate
                    if d
                        c.0.pause! if not c.0.paused!
                        c.0.progress 0
                    if e
                        c.1.pause! if not c.1.paused!
                        c.1.progress a
                    # save active
                    dat.active = b
                    # }}}
                | 'pointerup' =>
                    # drag stop
                    # {{{
                    # check
                    break if not dat.drag or dat.swipe
                    # prepare
                    event.stopPropagation!
                    # check active
                    if not (a = dat.active)
                        delete dat.drag
                        break
                    # determine current state
                    b = dat.drag[a.1].progress!
                    # check
                    if b < 0.35
                        # return to initial state
                        dat.drag[a.1].reverse!
                        delete dat.drag
                        break
                    # change model
                    dat.change a.0
                    # add refresher and play
                    a = dat.drag[a.1]
                    a.add P.refresh
                    return a.play!
                    # }}}
                | 'pointerover' =>
                    # hover
                    # {{{
                    # get node number
                    break if (a = event.target.dataset.num) == undefined
                    # prepare
                    event.stopPropagation!
                    # change model
                    a = +a
                    nav.currentItem[nav.current] = a
                    # set active state
                    cfg.data.btn.class.toggle 'active', (el, index) ->
                        index == a
                    # done
                    true
                    # }}}
                | 'keydown' =>
                    # focus / navigate
                    # {{{
                    # check
                    a = event.conf.keys.indexOf event.key
                    break if a < 0
                    # prepare
                    event.preventDefault!
                    event.stopImmediatePropagation!
                    # determine next index
                    b = nav.currentItem[nav.current]
                    c = cfg.data.btn
                    if a
                        # next
                        a = if b < c.length - 1
                            then b + 1
                            else 0
                    else
                        # previous
                        a = if b > 0
                            then b - 1
                            else c.length - 1
                    # change model
                    nav.currentItem[nav.current] = a
                    # set active state
                    c.class.toggle 'active', (el, index) ->
                        index == a
                    # }}}
                | 'click' =>
                    # navigate
                    # {{{
                    # prepare
                    event.stopPropagation!
                    # change navigation
                    a = cfg.level - 1
                    b = event.target.dataset.id
                    M[a] = b
                    P.update!
                    # }}}
                # }}}
            | 'console' =>
                switch nav.id
                | 'menu' =>
                    # {{{
                    # define model change routine
                    not dat.change and dat.change = (id) ->
                        # {{{
                        # prepare
                        # determine current
                        c = cfg.level + 1
                        a = M.nav[c].current or 0
                        # determine new current
                        b = cfg.context.data.length - 1
                        if id
                            b = if a < b
                                then a + 1
                                else 0
                        else
                            b = if a > 0
                                then a - 1
                                else b
                        # change
                        M.nav[c].current = b
                        # determine effect
                        # prepare
                        a = V.el.console.cfg.data.hover
                        b = V.el.menu.cfg.data.drag[id]
                        c =
                            a.0.progress! > 0.0001
                            a.1.progress! > 0.0001
                        # unhover first
                        if c.0 or c.1
                            d = b
                            b = new TimelineLite {
                                paused: true
                                ease: Power3.easeInOut
                            }
                            b.add a.0.reverse!.timeScale 2, 0 if c.0
                            b.add a.1.reverse!.timeScale 2, 0 if c.1
                            b.add d.play 0
                        # launch
                        # add refresher and play
                        b.add P.refresh
                        return b.play!
                        # }}}
                    # react
                    switch event.type
                    | 'pointerover' =>
                        # hover
                        # {{{
                        # prepare
                        event.stopPropagation!
                        a = V.el.console.cfg.data.hover
                        b = if event.conf.id == 'left'
                            then 0
                            else 1
                        # play
                        a[b].play!
                        # }}}
                    | 'pointerout' =>
                        # unhover
                        # {{{
                        # prepare
                        event.stopPropagation!
                        a = V.el.console.cfg.data.hover
                        b = if event.conf.id == 'left'
                            then 0
                            else 1
                        # play
                        a[b].reverse!
                        # }}}
                    | 'click' =>
                        # slide carousel
                        # {{{
                        event.stopPropagation!
                        a = if event.conf.id == 'left'
                            then 0
                            else 1
                        return dat.change a
                        # }}}
                    | 'keydown' =>
                        # keyboard
                        # {{{
                        # check
                        a = event.conf.keys.indexOf event.key
                        break if a < 0
                        # change menu
                        event.preventDefault!
                        event.stopImmediatePropagation!
                        return dat.change a if a < 2
                        # navigate
                        # get active element
                        for a in cfg.context.cfg.data.btn
                            break if a.class.has 'active'
                        # get id
                        a = a.dataset.id
                        # change model
                        M[cfg.level] = a
                        P.update!
                        # }}}
                    # }}}
            # done
            false
    # }}}
}
