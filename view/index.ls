'use strict'

w3ui and w3ui.ready ->
    M = w3ui.PROXY { # model {{{
        init: -> # {{{
            # initialize navigation store
            a = @nav
            @sav.forEach (save, level) !->
                save[''] = w3ui.CLONE a.slice level + 1
            # done
            true
        # }}}
        ###
        # interface navigation {{{
        nav: [
            {id: 'wa'}
            {id: 'view'}
            {id: 'menu'}
            {id: ''}
            {id: ''}
        ]
        sav: [{} {} {} {}]
        # }}}
        # user session {{{
        authorized: true
        # }}}
    }, {
        set: (obj, k, v, prx) -> # {{{
            # check
            return true if typeof k != 'string'
            # set model data
            a = parseInt k
            if isNaN a
                obj[k] = v
                return true
            # set navigation
            # prepare
            k = a
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
    V = # {{{
        init: (id = '', parent = null, level = 0, tid = '#t', templ) -> # {{{
            # get node
            if not (a = @ui[id]) or not (b = a.cfg)
                console.log 'getting of "'+id+'" failed'
                return false
            # prepare
            tid = tid + '-' + id if id
            id = b.id if not id
            if not templ
                # template is a DocumentFragment object
                templ = w3ui 'template', true
                templ = templ.0.content
            # initialize
            b.id       = id
            b.parent   = parent
            b.level    = level
            b.nav      = M.nav[level]
            b.render   = @render.bind a, b.render if b.render != undefined
            b.attach   = @attach.bind a, b.attach if b.attach
            b.template = templ.querySelector tid
            b.data     = {}
            # initialize show/hide animations
            # bind functions to the node
            b.show and b.show = b.show.map (c) ->
                return c if typeof c == 'object'
                return c.bind a
            b.hide and b.hide = b.hide.map (c) ->
                return c if typeof c == 'object'
                return c.bind a
            # recurse to children
            for own b,c of a when b != 'cfg' and c and c.cfg
                return false if not @init b, a, level + 1, tid, templ
            # complete
            true
        # }}}
        render: (template, id = @cfg.nav.id) -> # {{{
            # update node link
            if not @cfg.node
                @cfg.node = w3ui '#'+@cfg.id
            # determine node type
            a = @cfg.parent
            b = if not a or a.cfg.nav.id == @cfg.id
                then id
                else ''
            # update node context
            if not b and id and (c = a[a.cfg.nav.id][id])
                @cfg.context = c
            # check
            return true  if not template or not id
            return false if not @cfg.node
            # get template data
            if b
                # primary
                a = @[id].cfg.template.innerHTML
                c = @[id]
            else
                # adjacent
                a = @cfg.template.querySelector '#'+id .innerHTML
                c = @[id].render.call c
            # render
            @cfg.node.0.innerHTML = Mustache.render a, c
            # update child node link
            c.cfg.node = w3ui '#'+b if b
            true
        # }}}
        attach: (event) -> # {{{
            # check
            return true if not @cfg.node
            if event == true
                # adjacent event source
                # extract
                if not (a = @cfg.nav.id) or not (b = @[a])
                    return true
                # get event data
                event = b.attach
            # assemble event listeners
            x = /^key.+/
            e = []
            for own a,b of event
                b = [b] if not Array.isArray b
                for d in b
                    # get node
                    c = if d.el
                        then document.querySelectorAll '#'+@cfg.id+' '+d.el
                        else if d.el == ''
                            then [@cfg.node.0]
                            else [document]
                    # determine if default action prevented
                    d.preventDefault = not x.test a
                    # create event handler
                    # combined with custom data
                    d = P.event.bind @, d
                    # add
                    e.push [c, a, d]
            # check
            return true if not e.length
            # prepare detach procedure
            @cfg.detach = ->
                for [a, b, c] in e
                    a.forEach (a) !->
                        a.removeEventListener b, c
                # done
                delete @detach
                true
            # prepare data storage
            @cfg.detach.data = {}
            # attach
            for [a, b, c] in e
                a.forEach (a) !->
                    a.addEventListener b, c
            # done
            true
        # }}}
        walk: (id, direction, func, onComplete) -> # {{{
            # prepare
            # get start node
            return false if not a = @ui[id]
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
                b = b.reduce (a, b) -> return a ++ b
                , []
            # now we have two-dimensional walk array,
            # lets flatten it
            walk = walk.reduce (a, b) -> a ++ b
            , []
            # check direction
            walk.reverse! if not direction
            # walk
            # external function
            if typeof func != 'string'
                return walk.every (node) -> func.call node
            # walk
            # internal functions
            if onComplete
                # create thread
                a = []
                for b in walk when b.cfg[func]
                    # create chain unit
                    a.push let node = b
                        -> node.cfg[func].call node
                    # waiter
                    a.push let node = b
                        -> !node.cfg[func].busy
                # append final procedure
                a.push onComplete
                # execute
                w3ui.THREAD a
                # done
                return true
            # internal, no thread
            walk.every (node) -> if node.cfg[func]
                then node.cfg[func].call node
                else true
        # }}}
        ###
        ui: w3ui.PROXY { # {{{
            cfg: # {{{
                # common props
                id: 'ui'            # current node identifier
                node: w3ui '#ui'    # current DOM node
                root: null          # selected root
                parent: null        # backlink
                context: null       # primary context (for adjacent nodes)
                data: {}            # data storage
                level: 0            # node level in interface tree
                nav: null           # navigation for the level
                render: true        # render flag-function
                init: ->
                    # update root node link
                    a = @cfg.nav.id
                    b = if a
                        then V.ui[a]
                        else null
                    V.walk a, true, ->
                        @cfg.root = b
                        true
                    @cfg.root = b
                    true
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
                        init: -> # {{{
                            # done
                            true
                        # }}}
                        finit: -> # {{{
                            # set style
                            a = @cfg.nav.id
                            b = @cfg.node
                            if not b.hasClass a
                                b.removeClass!
                                b.addClass a
                            # done
                            true
                        # }}}
                    # }}}
                    menu: # {{{
                        cfg:
                            render: true
                            init: -> # {{{
                                # prepare
                                if not @cfg.data.menu
                                    @cfg.data.menu = @cfg.node.query '.box'
                                    @cfg.data.time = @cfg.show.1.duration
                                # initialize model
                                while (a = @cfg.nav.current) == undefined
                                    @cfg.nav.current = 0
                                while not (b = @cfg.nav.currentItem)
                                    @cfg.nav.currentItem = @data.map -> 0
                                # set pre-show style
                                @cfg.data.menu.class[a].add 'active'
                                true
                            # }}}
                            refresh: -> # {{{
                                # prepare
                                data = @cfg.data
                                #data.menu.addClass 'attached'
                                if not data.box
                                    # nodes
                                    a = @cfg.nav.current
                                    data.box = data.menu.eq a
                                    data.btn = data.box.query '.button'
                                    # numbers & ids
                                    for b from 0 to data.btn.length - 1
                                        data.btn[b].dataset.num = b
                                        data.btn[b].dataset.id = @data[a].list[b].id
                                    # style
                                    a = @cfg.nav.currentItem[@cfg.nav.current]
                                    data.btn.class[a].add 'active'
                                # initialize slide effect
                                # {{{
                                if not data.slide
                                    # prepare
                                    # determine indexes
                                    a = @cfg.nav.current or 0
                                    b = data.menu.length - 1
                                    c =
                                        if a > 0 then a - 1 else b # left
                                        if a < b then a + 1 else 0 # right
                                    # define transition items
                                    a =
                                        [data.menu[a], data.menu[c.0]]
                                        [data.menu[a], data.menu[c.1]]
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
                                                    # cleanup inline styles
                                                    data.menu.propRemove 'style'
                                                    # invalidate current data
                                                    delete data.slide
                                        }
                                        # step 0
                                        # initital state
                                        b.set a.0, {
                                            transformOrigin: '0% 50%'
                                            x: c[index].0
                                            zIndex: 1
                                        }
                                        b.set a.1, {
                                            transformOrigin: '0% 50%'
                                            x: c[index].2
                                            zIndex: 2
                                        }
                                        b.set a, {
                                            visibility: 'visible'
                                        }
                                        # step 1
                                        # move transition
                                        b.addLabel 's1'
                                        b.to a.0, data.time, {
                                            x: c[index].1
                                        }, 's1'
                                        b.to a.1, data.time, {
                                            x: c[index].3
                                        }, 's1'
                                        # finish
                                        b.set a.0, {className: '-=active'}
                                        b.set a.1, {className: '+=active'}
                                        # done
                                        b
                                # }}}
                                # initialize menu drag/swipe effect
                                # {{{
                                if not data.drag
                                    # get both slide effects
                                    a = V.ui.console.cfg.data.slide
                                    b = data.slide
                                    # create timelines
                                    c =
                                        new TimelineLite {paused: true, ease: Power3.easeInOut}
                                        new TimelineLite {paused: true, ease: Power3.easeInOut}
                                    # define startup routine
                                    d = !~>
                                        a = 'drag'
                                        b = not @cfg.node.hasClass a
                                        @cfg.node.toggleClass a, b
                                    # define complete routine
                                    e = (index) ~> !~>
                                        @cfg.node.removeClass 'drag'
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
                                    duration: 0
                                    tween:
                                        visibility: 'visible'
                                        scale: 0
                                }
                                {
                                    duration: 0.8
                                    tween:
                                        scale: 1
                                        ease: Back.easeOut
                                }
                                !-> @cfg.data.menu.addClass 'attached'
                            # }}}
                            hide: # {{{
                                !-> @cfg.data.menu.removeClass 'attached'
                                {
                                    duration: 0.8
                                    tween:
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
                                    tween:
                                        visibility: 'visible'
                                        scale: 0
                                }
                                {
                                    duration: 0.8
                                    tween:
                                        scale: 1
                                        ease: Back.easeOut
                                }
                            # }}}
                            hide: # {{{
                                {
                                    duration: 0.8
                                    tween:
                                        scale: 0
                                        ease: Back.easeIn
                                }
                                ...
                            # }}}
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
                    config: # {{{
                        empty: true
                    # }}}
                # }}}
                header: # {{{
                    cfg:
                        render: false
                        init: -> # {{{
                            # prepare
                            # collect DOM nodes
                            c = @cfg
                            d = c.data
                            if not d.title
                                d.title  = c.node.query '.title'
                                d.mode   = c.node.query '.mode .button'
                                d.config = c.node.query '.config .button'
                            # initialize show tween
                            c.show.1.tween.className = '+=on '+c.nav.id
                            # initialize title
                            # {{{
                            a = if c.context
                                then c.context.cfg.id
                                else ''
                            d.title.$text = if a
                                then @title[a]
                                else ''
                            d.title.html d.title.$text
                            # }}}
                            # initialize buttons
                            # {{{
                            if a
                                c = c.template
                                b = if a == 'menu'
                                    then 'close'
                                    else 'menu'
                                d.mode.$text = @mode[b]
                                d.mode.$icon = c.querySelector '#'+b .innerHTML
                                b = if a == 'config'
                                    then 'close'
                                    else 'config'
                                d.config.$text = @config[b]
                                d.config.$icon = c.querySelector '#'+b .innerHTML
                            # set state
                            d.mode.toggleClass 'disabled', !a
                            d.config.toggleClass 'disabled', !a
                            # }}}
                            # initialize button icon/text switch effect
                            # {{{
                            d.buttonSwitch = do ->
                                # create timelines
                                a =
                                    new TimelineLite {
                                        paused: true
                                        ease: Power2.easeIn
                                    }
                                    new TimelineLite {
                                        paused: true
                                        ease: Power2.easeIn
                                    }
                                a =
                                    [a.0, 'text', 'icon'] # text to icon
                                    [a.1, 'icon', 'text'] # reverse
                                # add tweens
                                a = a.map (a, index) ->
                                    # hide
                                    a.0.to d.mode, 0.4, {
                                        className: '-='+a.1
                                        scale: 0
                                    }, 0
                                    a.0.to d.config, 0.4, {
                                        className: '-='+a.1
                                        scale: 0
                                    }, 0
                                    # change content
                                    a.0.add let a = '$'+a.2
                                        !->
                                            d.mode.0.innerHTML = d.mode[a]
                                            d.config.0.innerHTML = d.config[a]
                                    # show
                                    a.0.addLabel 'L1'
                                    a.0.to d.mode, 0.4, {
                                        className: '+='+a.2
                                        scale: 1
                                    }, 'L1'
                                    a.0.to d.config, 0.4, {
                                        className: '+='+a.2
                                        scale: 1
                                    }, 'L1'
                                    a.0.add !->
                                        # remove inline styles
                                        d.mode.propRemove 'style'
                                        d.config.propRemove 'style'
                                    # done
                                    a.0
                                # done
                                a
                            # }}}
                            # initialize button resize routine
                            # {{{
                            d.buttonResize = !->
                                # check
                                a = d.buttonResize
                                b = d.buttonSwitch.some (a) ->
                                    a.isActive!
                                # animation in progress? zero font size?
                                if b or d.mode.style.fontSize < 0.0001
                                    # delay
                                    window.clearTimeout a.timer if a.timer
                                    a.timer = window.setTimeout d.buttonResize, 500
                                    return
                                # prepare
                                useIcon = [d.mode, d.config].some (el) ->
                                    # check if text fits
                                    if el.$text
                                        # get text width
                                        a = el.box.textMetrics el.$text .width
                                        # compare
                                        return true if el.box.innerWidth < a
                                    # continue
                                    false
                                # determine switch effect
                                a = d.mode.class.0
                                if useIcon and not a.contains 'icon'
                                    a = 0
                                else if not useIcon and not a.contains 'text'
                                    a = 1
                                else
                                    return
                                # set captions
                                a = d.buttonSwitch[a]
                                a.play 0
                            # }}}
                            true
                        # }}}
                        resize: -> # {{{
                            # prepare
                            c = @cfg
                            d = c.data
                            # calculate font size (title as base)
                            a = d.title.box.fontSize d.title.$text
                            b =
                                c.root.cfg.fontSizeMin
                                c.root.cfg.fontSizeMax
                            a = 0 if a < b.0
                            a = b.1 if a > b.1
                            # update root css variable
                            c.root.cfg.node.style.fSize0 = a+'px'
                            # resize buttons
                            d.buttonResize!
                            # done
                            true
                        # }}}
                        show: # {{{
                            {
                                duration: 0
                                tween:
                                    visibility: 'visible'
                            }
                            {
                                duration: 0.8
                                tween:
                                    className: ''
                                    opacity: 1
                                    ease: Power3.easeOut
                            }
                            !->
                                @cfg.resize.call @
                        # }}}
                        hide: # {{{
                            {
                                duration: 0.2
                                tween:
                                    opacity: 0
                                    ease: Power3.easeIn
                            }
                            {
                                duration: 0.4
                                tween:
                                    className: ''
                                    ease: Power3.easeIn
                            }
                        # }}}
                    attach: # {{{
                        click:
                            {
                                el: '.back .button'
                                id: 'back'
                            }
                            {
                                el: '.config .button'
                                id: 'config'
                            }
                    # }}}
                    title:
                        menu: 'Главное меню'
                        address: 'Картотека адресов'
                        config: 'Конфигурация'
                    mode:
                        menu: 'меню'
                        close: 'выход'
                    config:
                        config: 'настройки'
                        close: 'закрыть'
                # }}}
                console: # {{{
                    cfg: # {{{
                        render: true
                        attach: true
                        init: ->
                            # modify show tween
                            @cfg.show.1.tween.className = '+=on '+@cfg.nav.id
                            true
                        resize: ->
                            # invalidate data
                            for own a of @cfg.data
                                delete @cfg.data[a]
                            # refresh
                            @cfg.refresh.call @
                        refresh: ->
                            # prepare
                            a = @cfg.nav.id
                            b = @[a]
                            return true if not b or not b.refresh
                            # delegate
                            b.refresh.call @, @cfg.data
                        show: # {{{
                            {
                                duration: 0
                                tween:
                                    visibility: 'visible'
                            }
                            {
                                duration: 0.8
                                tween:
                                    className: ''
                                    opacity: 1
                                    ease: Power3.easeOut
                            }
                        # }}}
                        hide: # {{{
                            {
                                duration: 0.2
                                tween:
                                    opacity: 0
                                    ease: Power3.easeIn
                            }
                            {
                                duration: 0.4
                                tween:
                                    className: ''
                                    ease: Power3.easeIn
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
                            # prepare data
                            a = @data
                            b = @cfg.nav.current or 0
                            c = a.length - 1
                            d = a.map (item) ->
                                {
                                    id: item.id
                                    name: item.name
                                }
                            # done
                            return
                                list: d
                                current: a[b].name
                                prev: if b
                                    then a[b - 1].name
                                    else a[* - 1].name
                                next: if b == c
                                    then a.0.name
                                    else a[b + 1].name
                        # }}}
                        refresh: (data) -> # {{{
                            # initialize data
                            if not data.node
                                data.node = @cfg.node.query '.carousel'
                                data.time = @cfg.show.1.duration
                            if not data.box
                                data.box = data.node.query '.item'
                                data.btn = data.node.query '.button'
                            # initialize hover effect
                            # {{{
                            if not data.hover
                                # prepare
                                a = data.box
                                b = data.btn
                                # for left and right nodes
                                data.hover = [1, 3].map (index) ->
                                    # create timeline
                                    c = new TimelineLite {
                                        paused: true
                                        ease: Power2.easeOut
                                    }
                                    # un-hover at start
                                    c.add let a = a, b = b
                                        !->
                                            a.removeClass 'hover'
                                            b.removeClass 'hover'
                                    # hover
                                    c.to [a[index], b[index], a.2, b.2], data.time, {
                                        className: '+=hover'
                                    }
                                    # done
                                    c
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
                                data.btn.0.innerHTML = main.data[c.0].name
                                data.btn.4.innerHTML = main.data[c.1].name
                                # clone border nodes
                                a =
                                    data.box.node.0.clone!
                                    data.box.node.4.clone!
                                b =
                                    w3ui '.button', true, a.0
                                    w3ui '.button', true, a.1
                                # prepare list
                                a =
                                    [a.0, b.0.0]
                                    [a.1, b.1.0]
                                # create effect
                                data.slide = a.map (box, index) ->
                                    # create timeline
                                    a = new TimelineMax {
                                        paused: true
                                        data:
                                            complete: !->
                                                # cleanup inline styles
                                                data.box.propRemove 'style'
                                                data.btn.propRemove 'style'
                                                # change DOM
                                                if index
                                                    # +right -left
                                                    data.node.node.append box.0
                                                    data.box.node.0.remove!
                                                else
                                                    # -right +left
                                                    data.node.node.prepend box.0
                                                    data.box.node.4.remove!
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
                                    a.to data.box[index + 0], data.time, {
                                        className: b.0.0
                                    }, 0
                                    a.to data.box[index + 1], data.time, {
                                        className: b.0.1
                                    }, 0
                                    a.to data.box[index + 2], data.time, {
                                        className: b.0.2
                                    }, 0
                                    a.to data.box[index + 3], data.time, {
                                        className: b.0.3
                                    }, 0
                                    # button
                                    a.to data.btn[index + 0], data.time, {
                                        className: b.1.0
                                    }, 0
                                    a.to data.btn[index + 1], data.time, {
                                        className: b.1.1
                                    }, 0
                                    a.to data.btn[index + 2], data.time, {
                                        className: b.1.2
                                    }, 0
                                    a.to data.btn[index + 3], data.time, {
                                        className: b.1.3
                                    }, 0
                                    # done
                                    a
                            # }}}
                            # done
                            true
                        # }}}
                # }}}
        }, {
            get: (obj, id, prx) -> # {{{
                # check node
                # root
                return obj if not id
                return obj[id] if obj[id] and obj[id].cfg
                # leaf
                return null if not obj.cfg
                # branch
                # initiate searching
                a = [obj]
                while a.length
                    # extract node
                    b = a.pop!
                    # check sub-branches
                    for own k,v of b when k != 'cfg' and v and v.cfg
                        # found
                        return v[id] if v[id] and v[id].cfg
                        # add to stack
                        a.push v
                # not found
                return null
            # }}}
        }
        # }}}
    # }}}
    P = # {{{
        init: -> # {{{
            # initialize
            if not M.init! or not V.init!
                console.log 'init() failed'
                return false
            # construct
            P.construct!
            # attach global resize handler
            window.addEventListener 'resize', @resize.bind @
            # done
            true
        # }}}
        construct: (id = '') !-> # {{{
            # prepare
            me   = @construct
            node = V.ui[id]
            lock = false
            # start thread
            w3ui.THREAD [
                ->
                    # wait for global lock
                    return false if me.busy
                    me.busy = true
                    # detach events
                    if not V.walk id, false, 'detach'
                        console.log 'detach failed'
                        delete me.busy
                        return null
                    # hide
                    # {{{
                    # create timeline
                    a = new TimelineLite {
                        paused: true
                    }
                    V.walk id, false, ->
                        # prepare
                        if not (node = @cfg.node)
                            return true
                        # create effect timeline
                        b = new TimelineLite {paused: true}
                        # add tweens
                        @cfg.hide and @cfg.hide.forEach (a) !->
                            if a.tween
                                c = w3ui.CLONE a.tween
                                b.to node, a.duration, c
                            else
                                b.add a
                        # add timeline
                        a.add b.play!, 0
                        true
                    # set unlock
                    a.add !-> lock := false
                    # lock and play
                    lock := true
                    a.play!
                    # }}}
                    true
                ->
                    # wait
                    not lock
                ->
                    # cleanup
                    V.walk id, false, ->
                        # remove link
                        if @cfg.node and (a = @cfg.level) and @cfg.id != M[a - 1]
                            @cfg.node = null
                        # done
                        true
                    # render
                    a = ['render' 'init' 'resize' 'refresh'].every (f) ->
                        V.walk id, true, f
                    if not a
                        console.log 'render sequence failed'
                        delete me.busy
                        return null
                    # show
                    # {{{
                    # create timeline
                    a = new TimelineLite {
                        paused: true
                    }
                    # add startup label
                    b = 'L'+node.cfg.level
                    a.addLabel b, 0
                    # nest
                    V.walk id, true, ->
                        # check
                        if not (node = @cfg.node)
                            return true
                        # create effect timeline
                        c = new TimelineLite {
                            paused: true
                        }
                        # add tweens
                        @cfg.show and @cfg.show.forEach (a) !->
                            if a.tween
                                b = w3ui.CLONE a.tween
                                c.to node, a.duration, b
                            else
                                c.add a
                        # check label
                        if b != 'L'+@cfg.level
                            # update when level changes
                            b := 'L'+@cfg.level
                            a.addLabel b
                        # add timeline
                        a.add c.play!, b
                        true
                    # set unlock
                    a.add !-> lock := false
                    # lock and play
                    lock := true
                    a.play!
                    # }}}
                    true
                ->
                    # wait
                    not lock
                ->
                    # finalize
                    V.walk id, false, 'finit'
                    # attach events
                    if not V.walk id, true, 'attach'
                        console.log 'attach failed'
                    # unlock
                    delete me.busy
                    true
            ]
        # }}}
        update: (id = M.0) !-> # {{{
            # update view
            ['refresh' 'detach' 'attach'].every (f) ->
                V.walk id, true, f
            # unlock events
            delete P.event.busy
        # }}}
        ###
        resize: !-> # {{{
            # prepare
            me = @resize
            # activate debounce protection (delay)
            if me.timer
                # reset timer
                window.clearTimeout me.timer
                # set timer
                f = me.bind @
                me.timer = window.setTimeout f, 250
            # resize
            else if not V.walk '', true, 'resize'
                console.log 'resize failed'
        # }}}
        event: (data, event) -> # {{{
            # prepare
            me = P.event
            if data.preventDefault
                # we are self-sufficient,
                # always prevent default action!
                event.preventDefault!
            # check
            if P.construct.busy or not @cfg.detach or me.busy and not data.delayed
                return true
            # delay event
            if me.busy
                # dont bubble
                event.stopPropagation!
                # check waiter started
                a = !!me.delayed
                # create delayed routine
                me.delayed = me.bind @, data, event
                return false if a
                # speed up animations
                if typeof me.busy == 'object'
                    me.busy.timeScale 2
                # start waiter
                w3ui.THREAD [
                    ->
                        # wait
                        return false if me.busy
                        # process delayed event
                        me.delayed!
                        delete me.delayed
                        # finish
                        true
                ]
                return false
            # prepare data
            cfg = @cfg
            nav = @cfg.nav
            event.data = data
            data = cfg.detach.data
            # process event
            me.busy = P.react.apply @, [event, data, cfg, nav]
            true
        # }}}
        react: (event, data, cfg, nav) -> # {{{
            switch cfg.id
            | 'menu' =>
                # {{{
                # define menu change routine
                # {{{
                not data.change and data.change = (active) !~>
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
                    data.swipe = event.pointerType != 'mouse'
                    data.size = 0.5 * cfg.node.box.innerWidth
                    data.x = event.pageX
                    data.active = false
                    data.drag = V.ui.menu.cfg.data.drag
                    # }}}
                | 'pointermove' =>
                    # drag
                    # {{{
                    # check if started
                    break if not data.drag
                    # prepare
                    event.stopPropagation!
                    # determine drag distance
                    # and active timeline
                    if (a = event.pageX - data.x) < 0
                        b = [0 1]
                    else
                        b = [1 0]
                    # check
                    if (a = Math.abs a) < 0.1
                        # cancel drag
                        break if not data.swipe
                        # cancel swipe
                        delete data.drag
                        break
                    # select timelines
                    c = b.map (index) -> data.drag[index]
                    # determine position
                    a = a / data.size
                    a = 0.99 if a > 0.99
                    # swipe!
                    if data.swipe
                        # change model
                        data.change b.0
                        # play effect
                        delete data.drag
                        c.1.add P.update
                        return c.1.play!
                    # drag!
                    # check active
                    d = not data.active or data.active.0 != b.0
                    e = d or (Math.abs a - c.1.progress!) > 0.001
                    # animate
                    if d
                        c.0.pause! if not c.0.paused!
                        c.0.progress 0
                    if e
                        c.1.pause! if not c.1.paused!
                        c.1.progress a
                    # save active
                    data.active = b
                    # }}}
                | 'pointerup' =>
                    # drag stop
                    # {{{
                    # check
                    break if not data.drag or data.swipe
                    # prepare
                    event.stopPropagation!
                    # check active
                    if not (a = data.active)
                        delete data.drag
                        break
                    # determine current state
                    b = data.drag[a.1].progress!
                    # check
                    if b < 0.35
                        # return to initial state
                        data.drag[a.1].reverse!
                        delete data.drag
                        break
                    # change model
                    data.change a.0
                    # play to the end and update
                    a = data.drag[a.1]
                    a.add P.update
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
                    nav.currentItem[nav.current] = +a
                    # set focus
                    b = cfg.data.btn
                    b.removeClass 'active'
                    b.class[a].add 'active'
                    true
                    # }}}
                | 'keydown' =>
                    # focus / navigate
                    # {{{
                    # check
                    a = event.data.keys.indexOf event.key
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
                    # set focus
                    c.removeClass 'active'
                    c.eq a .addClass 'active'
                    # }}}
                | 'click' =>
                    # navigate
                    # {{{
                    # prepare
                    event.stopPropagation!
                    # change model
                    a = cfg.level - 1
                    b = event.target.dataset.id
                    M[a] = b
                    # construct
                    P.construct!
                    # }}}
                # }}}
            | 'console' =>
                switch nav.id
                | 'menu' =>
                    # {{{
                    # define model change routine
                    not data.change and data.change = (id) ->
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
                        # construct effect
                        a = V.ui.console.cfg.data.hover
                        b = V.ui.menu.cfg.data.drag[id]
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
                        # add update routine and play
                        b.add P.update
                        return b.play!
                        # }}}
                    # react
                    switch event.type
                    | 'pointerover' =>
                        # hover
                        # {{{
                        # prepare
                        event.stopPropagation!
                        a = V.ui.console.cfg.data.hover
                        b = if event.data.id == 'left'
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
                        a = V.ui.console.cfg.data.hover
                        b = if event.data.id == 'left'
                            then 0
                            else 1
                        # play
                        a[b].reverse!
                        # }}}
                    | 'click' =>
                        # slide carousel
                        # {{{
                        event.stopPropagation!
                        a = if event.data.id == 'left'
                            then 0
                            else 1
                        return data.change a
                        # }}}
                    | 'keydown' =>
                        # keyboard
                        # {{{
                        # check
                        a = event.data.keys.indexOf event.key
                        break if a < 0
                        # change menu
                        event.preventDefault!
                        event.stopImmediatePropagation!
                        return data.change a if a < 2
                        # navigate
                        # determine selected item
                        a = cfg.context.cfg.data.btn.find (node) ->
                            node.classList.contains 'active'
                        # get id
                        break if not a
                        a = a.dataset.id
                        # change model
                        M[cfg.level] = a
                        P.construct!
                        # }}}
                    # }}}
            # done
            false
        # }}}
    # }}}
    P.init! if M and V and P

