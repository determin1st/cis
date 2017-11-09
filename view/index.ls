'use strict'

w3ui and w3ui.ready ->
    M = w3ui.PROXY { # model {{{
        # navigation {{{
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
        init: (obj) -> # {{{
            # initialize navigation store
            a = obj.nav
            obj.sav.forEach (save, level) !->
                save[''] = w3ui.CLONE a.slice level + 1
            # done
            obj
        # }}}
        set: (obj, k, v, prx) -> # {{{
            # set data
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
                # get higher levels
                b = if d[v]
                    then d[v]
                    else w3ui.CLONE d['']
                # add them
                for d in b
                    a.push d
            # change
            c.id = v
            true
        # }}}
        get: (obj, p, prx) -> # {{{
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
        init: (model) -> # {{{
            # prepare
            # get templates (DocumentFragment object)
            template = document.querySelector 'template' .content
            # define functions
            init = (id, node, parent, level, tid) ~> # {{{
                # prepare
                cfg = node.cfg
                tid = tid + '-' + id if level > 0
                # initialize
                cfg.id       = id
                cfg.parent   = parent
                cfg.level    = level
                cfg.nav      = model.nav[level]
                cfg.render   = render.bind node, cfg.render if cfg.render != undefined
                cfg.attach   = attach.bind node, cfg.attach if cfg.attach
                cfg.template = template.querySelector tid
                cfg.data     = {}
                # initialize show/hide animations
                # bind functions to the node
                cfg.show and cfg.show = cfg.show.map (a) ->
                    return a if typeof a == 'object'
                    return a.bind node
                cfg.hide and cfg.hide = cfg.hide.map (a) ->
                    return a if typeof a == 'object'
                    return a.bind node
                # recurse to children
                for own a,b of node when a != 'cfg' and b and b.cfg
                    init a, b, node, level + 1, tid
                # complete
                true
                # }}}
            render = (template, old = '') -> # {{{
                # prepare
                # get identifier from model
                id = @cfg.nav.id
                # update DOM node link
                if not @cfg.node
                    @cfg.node = w3ui '#'+@cfg.id
                # determine node type
                a = @cfg.parent
                b = if not a or a.cfg.nav.id == @cfg.id
                    then id
                    else ''
                # update adjacent node context
                if not b and id and (c = a[a.cfg.nav.id][id])
                    @cfg.context = c
                # check
                return true  if not template or not id
                return false if not @cfg.node
                # get template data
                if b
                    # for primary
                    a = @[id].cfg.template.innerHTML
                    c = @[id]
                else
                    # for adjacent
                    a = @cfg.template.querySelector '#'+id .innerHTML
                    c = @[id].render.call c
                # render
                a = Mustache.render a, c
                if a and b
                    # primary container
                    # create element
                    d = document.createElement 'template'
                    d.innerHTML = a
                    b = w3ui '#'+b, d.content
                    # set display:none
                    b.style.display = 'none'
                    # check old present
                    if old
                        # insert
                        @cfg.node.child.insert b
                    else
                        # replace
                        @cfg.node.child.remove!
                        @cfg.node.child.add b
                    # update child link
                    c.cfg.node = b
                else
                    # adjacent container
                    # replace content
                    @cfg.node.html = a
                # done
                true
            # }}}
            attach = (event) -> # {{{
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
                                then [@cfg.node]
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
            # initialize
            @animation = @animation!
            @el.$data  = @ui
            @el.$model = model
            return init 'ui', @ui, null, 0, '#t'
        # }}}
        animation: -> # {{{
            # define helpers
            addTweens = (node, timeline, source) !-> # {{{
                node = node.w3ui.group
                source and source.forEach (a) !->
                    switch typeof a
                    # tween
                    | 'object' =>
                        # check
                        break if not a.to and not a.from
                        # prepare
                        b =
                            if a.to
                                then w3ui.CLONE a.to
                                else null
                            if a.from
                                then w3ui.CLONE a.from
                                else null
                        c = if a.position
                            then a.position
                            else '+=0'
                        # set
                        if not a.duration or a.duration < 0.0001
                            timeline.set node, (b.0 or b.1), c
                            break
                        # animate to
                        if b.0 and not b.1
                            timeline.to node, a.duration, b.0, c
                            break
                        # animate from
                        if not b.0 and b.1
                            timeline.from node, a.duration, b.1, c
                            break
                        # animate fromTo
                        timeline.fromTo node, a.duration, b.0, b.1, c
                    # add callback
                    | 'function' =>
                        timeline.add a
                    # add label
                    | 'string' =>
                        timeline.addLabel a
            # }}}
            # define animations
            return {
                hide: (id, onComplete) !~> # {{{
                    # prepare
                    if not id or not (list = @list id) or not list.length
                        onComplete!
                        return
                    # dont include first (parent) node and
                    # set iteration in reverse order
                    list = list.slice 1
                    list.reverse!
                    # create main timeline
                    a = new TimelineLite {
                        paused: true
                    }
                    b = ''
                    # iterate
                    list.forEach (node) !->
                        # get DOM node
                        return if not (node = @cfg.node)
                        # create timeline
                        c = new TimelineLite {
                            paused: true
                        }
                        # add tweens
                        addTweens node, c, @cfg.hide
                        # add marker
                        if not b or b != 'L'+@cfg.level
                            b := 'L'+@cfg.level
                            a.addLabel b
                        # nest
                        a.add c.play!, b
                        # ..
                    # add complete routine
                    a.add onComplete
                    # done
                    a.play!
                # }}}
                show: (id1, id0, onComplete) !~> # {{{
                    # prepare
                    node1  = @el[id1].cfg
                    node0  = @el[id0].cfg
                    list   = @list id1
                    parent = node1.parent.cfg
                    turn   = null
                    old    = null
                    if id0
                        turn = parent.turn
                        old  = (parent.node.query '#'+id0, 0, true).0
                    # create main timeline
                    a = new TimelineLite {
                        paused: true
                    }
                    # add node turn transition (old ~> new)
                    if turn
                        # exclude new node from show-list
                        list = list.slice 1
                        # prioritize
                        # check children nodes
                        if node0.turn or node1.turn
                            turn = if node1.turn
                                then node1.turn
                                else node0.turn
                        # clear display property
                        a.add !->
                            node1.node.style.display = null
                        a.addLabel 'start'
                        # turn off
                        b = new TimelineLite {paused: true}
                        addTweens old, b, turn.off
                        a.add b.play!, 'start'
                        # turn on
                        b = new TimelineLite {paused: true}
                        addTweens node1.node, b, turn.on
                        a.add b.play!, 'start'
                    # add old node remover
                    old and a.add !->
                        parent.node.child.remove old
                    # filter show-list
                    list = list.reduce (a, b) ->
                        # active only
                        a.push b if b.cfg.node
                        # done
                        return a
                    , []
                    # show transition
                    b = ''
                    list.forEach (el) !->
                        # prepare
                        el = el.cfg
                        # create timeline
                        c = new TimelineLite {paused: true}
                        # add tweens
                        c.add !-> el.node.style.display = null
                        addTweens el.node, c, el.show
                        # add marker
                        if not b or b != 'L'+el.level
                            # update it when level changes,
                            # so nodes at the same level show together
                            b := 'L'+el.level
                            a.addLabel b
                        # nest
                        a.add c.play!, b
                        true
                    # add complete routine
                    a.add onComplete
                    # done
                    a.play!
                # }}}
            }
        # }}}
        el: w3ui.PROXY null, { # {{{
            get: (obj, id, prx) ->
                # check if all roots requested
                return obj if obj.cfg.id == id
                # get root id
                if not (root = prx.$model.0)
                    return null
                # get root element
                if not (obj = obj[root])
                    return null
                # check
                return obj if not id or obj.cfg.id == id
                return obj[id] if obj[id] and obj[id].cfg
                # search
                a = [obj]
                while a.length
                    # extract node
                    b = a.pop!
                    # iterate
                    for own k,v of b when k != 'cfg' and v and v.cfg
                        # check
                        if v[id] and v[id].cfg
                            return v[id]
                        # not found
                        a.push v
                # not found
                return null
        }
        # }}}
        list: (id) -> # {{{
            # prepare
            # get node
            x = []
            if not (a = @el[id])
                return x
            # iterate
            b = [a]
            while b.length
                # add step
                x.push b
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
            # now we have two-dimensional array,
            # lets flatten it
            x = x.reduce (a, b) -> a ++ b
            , []
            # done
            return x
            # }}}
        call: (method, id = '', ...param) -> # {{{
            # prepare
            me = @call
            # define method options
            # {{{
            not me.opts and me.opts =
                render:
                    active: false
                init:
                    active: true
                    cleanup: true
                resize:
                    active: true
                refresh:
                    active: true
                attach:
                    active: true
                detach:
                    active: true
                    reverse: true
                finit:
                    active: true
                    reverse: true
            # }}}
            # get options
            if not (opts = me.opts[method])
                return false
            # get node list
            if not (list = @list id)
                return false
            # reverse list
            if opts.reverse
                list.reverse!
            # apply filters
            # {{{
            # remove nodes without specified method
            list = list.reduce (a, node) ->
                a.push node if node.cfg[method]
                return a
            , []
            # remove inactive node links
            if opts.cleanup
                list.forEach (node) !->
                    # prepare
                    a = node.cfg
                    return if not a.node
                    # get primary node
                    b = if a.context
                        then a.context.cfg
                        else a
                    # check current navigation
                    return if b.parent.cfg.nav.id == b.id
                    # cleanup
                    a.node = null
            # remove inactive nodes
            if opts.active
                list = list.reduce (a, node) ->
                    a.push node if node.cfg.node
                    return a
                , []
                true
            # }}}
            # check parameter
            param = false if not param.length
            # call
            return list.every (node) ->
                if param
                    then node.cfg[method].apply node, param
                    else node.cfg[method].call node
            # }}}
        ###
        ui: # {{{
            cfg: # {{{
                id: 'ui'            # node identifier
                node: w3ui '#ui'    # DOM node
                parent: null        # backlink
                context: null       # primary context (for adjacent nodes)
                data: {}            # data storage
                level: 0            # node level in interface tree
                nav: null           # navigation (next level)
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
                            refresh: -> # {{{
                                # prepare
                                data = @cfg.data
                                if not data.box
                                    # nodes
                                    a = @cfg.nav.current
                                    data.box = data.menu[a]
                                    data.btn = data.box.query '.button'
                                    # numbers & ids
                                    for b from 0 to data.btn.length - 1
                                        data.btn[b].dataset.num = b
                                        data.btn[b].dataset.id = @data[a].list[b].id
                                    # style
                                    a = @cfg.nav.currentItem[a]
                                    data.btn[a].class.add 'active'
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
                                    a = V.el.console.cfg.data.slide
                                    b = data.slide
                                    # create timelines
                                    c =
                                        new TimelineLite {paused: true, ease: Power3.easeInOut}
                                        new TimelineLite {paused: true, ease: Power3.easeInOut}
                                    # define startup routine
                                    d = !~>
                                        a = 'drag'
                                        b = not @cfg.node.class.has a
                                        @cfg.node.class.toggle a, b
                                    # define complete routine
                                    e = (index) ~> !~>
                                        @cfg.node.class.remove 'drag'
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
                                        visibility: 'visible'
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
                            c.show.1.to.className = '+=on '+c.nav.id
                            # initialize title
                            # {{{
                            a = if c.context
                                then c.context.cfg.id
                                else ''
                            d.title.$text = if a
                                then @title[a]
                                else ''
                            d.title.html = d.title.$text
                            # }}}
                            # initialize buttons
                            # {{{
                            if a
                                c = c.template
                                b = if a == 'menu'
                                    then 'return'
                                    else 'menu'
                                d.mode.$text = @mode[b]
                                d.mode.$icon = c.querySelector '#'+b .innerHTML
                                b = if a == 'config'
                                    then 'close'
                                    else 'config'
                                d.config.$text = @config[b]
                                d.config.$icon = c.querySelector '#'+b .innerHTML
                            # set state
                            d.mode.class.toggle 'disabled', !a
                            d.config.class.toggle 'disabled', !a
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
                                    a.0.to d.mode.node, 0.4, {
                                        className: '-='+a.1
                                        scale: 0
                                    }, 0
                                    a.0.to d.config.node, 0.4, {
                                        className: '-='+a.1
                                        scale: 0
                                    }, 0
                                    # change content
                                    a.0.add let a = '$'+a.2
                                        !->
                                            d.mode.html   = d.mode[a]
                                            d.config.html = d.config[a]
                                    # show
                                    a.0.addLabel 'L1'
                                    a.0.to d.mode.node, 0.4, {
                                        className: '+='+a.2
                                        scale: 1
                                    }, 'L1'
                                    a.0.to d.config.node, 0.4, {
                                        className: '+='+a.2
                                        scale: 1
                                    }, 'L1'
                                    a.0.add !->
                                        # remove inline styles
                                        d.mode.prop.style   = null
                                        d.config.prop.style = null
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
                                        # use icon
                                        return true if el.box.innerWidth < a
                                    # use text
                                    false
                                # determine switch effect
                                a = d.mode.class
                                if useIcon and not a.has 'icon'
                                    a = 0
                                else if not useIcon and not a.has 'text'
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
                            c = V.el.wa.cfg
                            d = @cfg.data
                            # calculate font size (title as base)
                            a = d.title.box.fontSize d.title.$text
                            b =
                                c.fontSizeMin
                                c.fontSizeMax
                            a = 0 if a < b.0
                            a = b.1 if a > b.1
                            # update css variable
                            c.node.style.fSize0 = a+'px'
                            # resize buttons
                            d.buttonResize!
                            # done
                            true
                        # }}}
                        show: # {{{
                            {
                                duration: 0
                                to:
                                    visibility: 'visible'
                            }
                            {
                                duration: 0.8
                                to:
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
                                to:
                                    opacity: 0
                                    ease: Power3.easeIn
                            }
                            {
                                duration: 0.4
                                to:
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
                        return: 'возврат'
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
                            @cfg.show.1.to.className = '+=on '+@cfg.nav.id
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
                                to:
                                    visibility: 'visible'
                            }
                            {
                                duration: 0.8
                                to:
                                    className: ''
                                    opacity: 1
                                    ease: Power3.easeOut
                            }
                        # }}}
                        hide: # {{{
                            {
                                duration: 0.2
                                to:
                                    opacity: 0
                                    ease: Power3.easeIn
                            }
                            {
                                duration: 0.4
                                to:
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
                # }}}
        # }}}
    # }}}
    P = # {{{
        init: -> # {{{
            # initialize
            if not V.init M
                console.log 'P.init() failed'
                return false
            # construct
            P.construct!
            # attach global resize handler
            window.addEventListener 'resize', @resize.bind @
            # done
            true
        # }}}
        ###
        construct: do !-> # {{{
            # define vars
            busy   = false      # main lock
            lock   = false      # thread lock
            nav    = null       # previous navigation
            id0    = ''         # previous (old)
            id1    = ''         # new
            level  = 0          # change level
            pid    = ''         # parent
            # define helper functions
            cancelThread = (msg) ->
                # display message
                console.log msg if msg
                # unlock
                lock := false
                busy := false
                # break
                null
            # define thread
            thread = [
                ->
                    # wait
                    not busy
                ->
                    # initialize thread
                    # lock
                    busy := true
                    # check navigation to
                    # determine first changed id
                    if nav
                        for a,b in nav when a != M[b]
                            id0   := a
                            id1   := M[b]
                            level := b
                            break
                    else
                        id1 := M.0
                    # cancel if there is no change
                    return cancelThread! if id0 == id1
                    # cancel if change node is undefined
                    if not (a = V.el[id1])
                        # restore navigation
                        M[level] = id0
                        return cancelThread '"'+id1+'" not found'
                    # get parent id
                    pid := a.cfg.parent.cfg.id
                    # detach events
                    if not V.call 'detach'
                        return cancelThread 'detach failed'
                    # hide
                    if id0
                        lock := true
                        V.animation.hide id0, !-> lock := false
                    # continue
                    true
                ->
                    # wait
                    not lock
                ->
                    # render
                    if not V.call 'render', pid, id0
                        return cancelThread 'render failed'
                    # initialize
                    if not V.call 'init'
                        return cancelThread 'init failed'
                    # show
                    lock := true
                    V.animation.show id1, id0, !-> lock := false
                    # continue
                    true
                ->
                    # wait
                    not lock
                ->
                    # finalize
                    ['resize' 'refresh' 'finit' 'attach'].every (a) -> V.call a
                    # save navigation and unlock
                    nav  := M.nav.map (a) -> a.id
                    busy := false
                    # done
                    true
            ]
            # construct routine
            return !->
                w3ui.THREAD thread
        # }}}
        update: (id = M.0) !-> # {{{
            # update view
            ['refresh' 'detach' 'attach'].every (a) -> V.call a, id
            # unlock events
            delete P.event.busy
        # }}}
        ###
        resize: (force) !-> # {{{
            # prepare
            me = @resize
            if force or not me.timer
                # resize
                if not V.call 'resize'
                    console.log 'resize failed'
            else
                # activate debounce protection (delay)
                # reset timer
                window.clearTimeout me.timer
                # set timer
                f = me.bind @
                me.timer = window.setTimeout f, 250
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
                    data.drag = V.el.menu.cfg.data.drag
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
                        a = V.el.console.cfg.data.hover
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
                        a = V.el.console.cfg.data.hover
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
                        # get active element
                        for a in cfg.context.cfg.data.btn
                            break if a.class.has 'active'
                        # get id
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

