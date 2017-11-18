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
            k   = a
            nav = obj.nav
            a   = nav[k]
            sav = if k < obj.sav.length
                then obj.sav[k]
                else null
            # no change
            return true if a.id == v == ''
            # reset
            v = '' if a.id == v
            # backup/restore
            if sav
                # backup
                k++
                sav[a.id] = w3ui.CLONE nav.slice k
                # clear higher levels
                for b from k to nav.length - 1
                    w3ui.clearObject nav[b]
                #nav.splice k + 1
                # get previous data
                sav = if sav[v]
                    then sav[v]
                    else sav['']
                # restore
                for b,c in sav
                    nav[k + c] <<< sav[c]
            # change
            a.id = v
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
            @animation = @animation!
            @el.$data  = @ui
            @el.$model = model
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
                # initialize animations
                cfg.show and @animation.init node, cfg.show
                cfg.hide and @animation.init node, cfg.hide
                if cfg.turn
                    if cfg.turn.on
                        @animation.init node, cfg.turn.off
                        @animation.init node, cfg.turn.on
                    else
                        @animation.init node, cfg.turn
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
                # check if render required
                return true  if not template or not id
                return false if not @cfg.node
                # get template data
                if b
                    # for primary
                    a = @[id].cfg.template.innerHTML
                    c = @[id]
                else
                    # for adjacent
                    a = if (a = @cfg.template.querySelector '#'+id)
                        then a.innerHTML
                        else ''
                    c = if @[id]
                        then @[id].render.call @
                        else null
                # render
                return true if not (a = Mustache.render a, c)
                # create DOM template
                d = document.createElement 'template'
                d.innerHTML = a.trim!
                # get rendered element(s)
                c = if b
                    then w3ui '#'+b, d.content
                    else w3ui '', d.content
                # set display:none
                c.style.display = 'none'
                # check old present
                if old
                    # insert
                    @cfg.node.child.insert c
                else
                    # replace
                    @cfg.node.child.remove!
                    @cfg.node.child.add c
                # update child link
                if b
                    # primary
                    @[id].cfg.node = c
                else
                    # adjacent
                    @[id].node = c
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
            return init 'ui', @ui, null, 0, '#t'
        # }}}
        animation: -> # {{{
            # define helpers
            # TODO {{{
            api =
                pauseAll: !-> # {{{
                    a = @
                    do
                        a.pause!
                    while (a = a.timeline)
                # }}}
                resumeAll: !-> # {{{
                    a = @
                    do
                        a.resume! if not a.isActive!
                    while (a = a.timeline)
                # }}}
                removeAtLabel: (label) -> # TODO {{{
                    # get label
                    if (a = @getLabelTime label) == -1
                        return
                    # get children
                    b = @getChildren false, true, true, a
                    # iterate and remove
                    for c in b when c.startTime! == a
                        console.log 'found a tween to remove at [' + label + ']'
                        @remove c
                # }}}
            apiHandler =
                get: (obj, key) ->
                    return api[key].bind obj if api[key]
                    return Reflect.get obj, key
            # }}}
            addTweens = (node, timeline, source, noPosition) !-> # {{{
                # get DOM nodes
                if not node or ('length' of node and not node.length)
                    return
                if 'w3ui' of node
                    node = node.w3ui.group
                # iterate
                source and source.forEach (a) !->
                    switch typeof a
                    # tween
                    | 'object' =>
                        # prepare
                        node := a.node if a.node
                        pos = if a.position and not noPosition
                            then a.position
                            else '+=0'
                        # check node
                        if not node or ('length' of node and not node.length)
                            break
                        # check object type
                        # label
                        if a.label
                            timeline.addLabel a.label, pos
                            break
                        # callback
                        if a.func
                            timeline.add a.func, pos
                            break
                        # group
                        if a.group
                            b = new TimelineLite {paused:true}
                            addTweens node, b, a.group
                            b.duration a.duration if a.duration
                            timeline.add b.play!, pos
                            break
                        # animation tween
                        break if not a.to and not a.from
                        # prepare
                        b =
                            if a.to
                                then w3ui.CLONE a.to
                                else null
                            if a.from
                                then w3ui.CLONE a.from
                                else null
                        # set
                        if not a.duration or a.duration < 0.0001
                            timeline.set node, (b.0 or b.1), pos
                            break
                        # animate to
                        if b.0 and not b.1
                            timeline.to node, a.duration, b.0, pos
                            break
                        # animate from
                        if not b.0 and b.1
                            timeline.from node, a.duration, b.1, pos
                            break
                        # animate fromTo
                        timeline.fromTo node, a.duration, b.0, b.1, pos
                    # add callback
                    | 'function' =>
                        if a.length
                            b = new Proxy timeline, apiHandler
                            timeline.addPause '+=0', a, [b]
                        else
                            timeline.add a
                    # add label
                    | 'string' =>
                        timeline.addLabel a
            # }}}
            # construct
            return {
                init: (node, tweens) !-> # {{{
                    # bind tween functions
                    for a,b in tweens
                        # check type
                        if typeof a == 'function'
                            tweens[b] = a.bind node
                            continue
                        # check object type
                        if a.func
                            tweens[b].func = a.func.bind node
                            continue
                        # recurse
                        if a.group
                            @init node, a.group
                # }}}
                queue: (node, queue) -> # {{{
                    # create timeline
                    a = new TimelineLite {paused:true}
                    # add tweens
                    addTweens node, a, queue, true
                    # done
                    return a
                # }}}
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
                    # create main timeline
                    x = new TimelineLite {
                        paused: true
                    }
                    x.addLabel 'turn'
                    # TURN transition (old ~> new)
                    # {{{
                    node   = @el[id1].cfg
                    parent = node.parent
                    if id0 and (c = parent.cfg.parent)
                        # create list
                        list = [parent]
                        # add adjacent nodes
                        for a,b of c when a != 'cfg' and b.cfg
                            # skip inactive and primary
                            if not b.cfg.node or a == parent.cfg.id
                                continue
                            # add
                            list.push b
                        # walk through list
                        list.forEach (parent) !->
                            # prepare
                            el0  = parent[id0]
                            el1  = parent[id1]
                            turn = parent.cfg.turn
                            flag = !!parent.cfg.context
                            # check old node
                            if flag and (not el0 or not el0.render) and (not el1 or not el1.render)
                                # adjacent parent,
                                # with simple turn effect
                                if turn
                                    a = new TimelineLite {paused: true}
                                    addTweens parent.cfg.node, a, turn
                                    x.add a.play!, 'turn'
                                return
                            # get old node
                            if flag
                                # adjacent parent
                                old = el0.node if el0
                            else
                                # primary parent
                                el0 = el0.cfg
                                el1 = el1.cfg
                                old = parent.cfg.node.query '#'+id0, 0, true .0
                            # check transition defined
                            if not turn
                                # add old node remover
                                old and x.add !->
                                    parent.cfg.node.child.remove old
                                    delete el0.node if el0.node
                                # done
                                return
                            # prioritize turn
                            turn =
                                on: if el1 and el1.turn
                                    then el1.turn.on
                                    else turn.on
                                off: if el0 and el0.turn
                                    then el0.turn.off
                                    else turn.off
                            # turn on
                            if el1
                                # create effect
                                a = new TimelineLite {paused: true}
                                # show parent,
                                # if there is no old node
                                if not old and parent.cfg.show
                                    addTweens parent.cfg.node, a, parent.cfg.show
                                # clear display property (for primary parent)
                                not flag and x.add !->
                                    el1.node.style.display = null
                                , 'turn'
                                # turn on new node
                                addTweens el1.node, a, turn.on
                                # nest
                                x.add a.play!, 'turn'
                            # turn off
                            if old
                                # create effect
                                a = new TimelineLite {paused: true}
                                # turn off old node
                                addTweens old, a, turn.off
                                # hide parent,
                                # if there is no new node
                                if not el1 and parent.cfg.hide
                                    addTweens parent.cfg.node, a, parent.cfg.hide
                                # nest
                                x.add a.play!, 'turn'
                                # add old node remover
                                x.add !->
                                    parent.cfg.node.child.remove old
                                    delete el0.node
                    # }}}
                    # SHOW transition (primary parent)
                    # {{{
                    # create show-list
                    list = @list id1
                    # filter
                    # remove new node if turn transition set
                    list = list.slice 1 if id0
                    # active only
                    list = list.reduce (a, b) ->
                        a.push b if b.cfg.node
                        return a
                    , []
                    # add effects
                    a = ''
                    list.forEach (elem) !->
                        # prepare
                        # create timeline
                        b = elem.cfg
                        c = new TimelineLite {paused: true}
                        # add tweens
                        # reset inline display style
                        c.add !->
                            # get node
                            if b.context
                                c = elem[b.nav.id]
                                c.node.style.display = null if c
                            else
                                b.node.style.display = null
                        # show
                        addTweens b.node, c, b.show
                        # add marker
                        if not a or a != 'L'+b.level
                            # update it when level changes,
                            # so nodes at the same level show together
                            a := 'L'+b.level
                            c.addLabel a
                        # nest
                        x.add c.play!, a
                    # }}}
                    # add complete routine
                    x.add onComplete
                    # launch
                    x.play!
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
                    active: false
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
                            finit: -> # {{{
                                # prepare
                                w3ui.clearObject @cfg.data
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
                            dat.resizeAnim = V.animation.queue cfg.node, [
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
                            dat = cfg.data
                            # determine workarea font size
                            # {{{
                            a = dat.title.box.fontSize dat.title.$text
                            c = V.el.wa.cfg
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
                                    opacity: 0
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
                            # initialize animations
                            #debugger
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
            rid    = ''         # render root id
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
                    # determine render root
                    a = a.cfg.parent
                    a = a.cfg.parent if a.cfg.parent
                    rid := a.cfg.id
                    # detach events
                    if not V.call 'detach'
                        return cancelThread 'detach failed'
                    # hide
                    if id0
                        lock := true
                        V.animation.hide id0, !-> lock := false
                    # finalize
                    if not V.call 'finit', id1
                        return cancelThread 'finit failed'
                    # continue
                    true
                ->
                    # wait
                    not lock
                ->
                    # render
                    if not V.call 'render', rid, id0
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
                    ['resize' 'refresh' 'attach'].forEach (a) ->
                        V.call a
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
            | 'header' =>
                # {{{
                # prepare
                a = event.currentTarget.dataset.id
                # kill hover animation
                b = @cfg.data[a]
                b.$anim.kill! if b.$anim
                # proceed
                switch event.type
                | 'pointerover' =>
                    # hover
                    # {{{
                    if @cfg.data.useIcon
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
                    if @cfg.data.useIcon
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
                    b = @cfg.nav.id
                    if a == 'mode' and b == 'menu'
                        # close main menu of workareas,
                        # return to selector
                        # ..
                        break
                    else if a == 'config'
                        if b == 'config'
                            # close configuration,
                            # return to workarea
                            M[@cfg.level] = M.nav[@cfg.level + 1].current
                        else
                            # open configuration,
                            # close workarea
                            M[@cfg.level] = 'config'
                            M.nav[@cfg.level + 1].current = b
                    else
                        # return to main menu,
                        # close workarea
                        M[@cfg.level] = 'menu'
                    # go
                    P.construct!
                    # }}}
                # }}}
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

