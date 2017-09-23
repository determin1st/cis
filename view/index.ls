'use strict'

#######
$ \document .ready ->
    ###
    return if not w3ui
    ###
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
        skel: w3ui.PROXY { # interface skeleton {{{
            cfg: # {{{
                # common props
                id: 'skel'          # DOM node identifier
                node: w3ui '#skel'  # DOM node object
                root: w3ui 'html'   # DOM root
                parent: null        # backlink
                context: null       # primary context (for adjacent node)
                data: {}            # data storage
                level: 0            # node level in skeleton tree
                nav: null           # navigation for the level
                namespace: ''       # event namespace
                render: true        # render flag-function
                refresh: ->
                    # update document width/height css variable
                    a = @cfg.root.box.innerWidth
                    b = @cfg.root.box.innerHeight
                    @cfg.root.style.vWidth  = a
                    @cfg.root.style.vHeight = b
                    @cfg.root.style.vPerspective = a + 'px'
                    true
            # }}}
            wa:
                cfg: # {{{
                    fontSizeMax: 0
                    init: -> # {{{
                        # collect DOM nodes
                        # buttons
                        for own a,b of @header.buttons
                            b.node = w3ui '#header .'+a+' .button'
                        # title
                        @header.title.node = w3ui '#header .title'
                        # inititalize font size
                        a = parseInt @cfg.node.style.fSizeMax
                        @cfg.fontSizeMax = a if not isNaN a
                        true
                    # }}}
                    resize: -> # {{{
                        # let's calculate base font size
                        # determine maximal value
                        a = @cfg.fontSizeMax
                        b = @header.title
                        b = b.node.textMeasureFont b.text
                        b = a if b > a
                        # update css variable
                        @cfg.node.style.fSize0 = b+'px'
                        # fit button captions
                        for own a,b of @header.buttons
                            # reset
                            if not b.list
                                b.index = -1
                                continue
                            # determine index
                            b.index = b.list.reduce (a, text, index) ->
                                # measure string
                                c = b.node.textMeasure text
                                # check if it fits and length of the string
                                # is greater than previous
                                if (c.width < b.node.box.innerWidth) and
                                   (a < 0 or b.list[a].length < text.length)
                                    # new index
                                    return index
                                # previous index
                                return a
                            , -1
                        # done
                        true
                    # }}}
                    refresh: -> # {{{
                        # set button captions
                        for own a,b of @header.buttons
                            # check
                            if not b.list
                                b.node.addClass 'disabled'
                                b.node.html ''
                                continue
                            # set
                            b.node.removeClass 'disabled'
                            b.node.html if b.index < 0
                                then b.icon
                                else b.list[b.index]
                        # done
                        true
                    # }}}
                    show: # {{{
                        {
                            duration: 0
                            tween:
                                opacity: 0
                                visibility: 'visible'
                        }
                        {
                            duration: 0.4
                            tween:
                                opacity: 1
                                ease: Power1.easeOut
                        }
                    # }}}
                    attach: # {{{
                        click:
                            ['#header .b1 .button' 'mode']
                            ['#header .b2 .button' 'config']
                    # }}}
                # }}}
                view: # {{{
                    cfg: # {{{
                        render: true
                        init: -> # {{{
                            # initialize header
                            p = @cfg.parent
                            a = @cfg.nav.id
                            b = p.header.buttons
                            c = if a
                                then @[a]
                                else null
                            # navigation
                            b.b1.list = if a != 'menu'
                                then @menu.title
                                else null
                            # config
                            b.b2.list = if c and c.config
                                then @config.title
                                else null
                            # title
                            b = p.header
                            b.title.text = if c and c.title
                                then c.title.0
                                else ''
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
                                # set style
                                a = @cfg.node.find '.box'
                                b = @cfg.nav.current or 0
                                a.eq b .addClass 'active'
                                true
                            # }}}
                            refresh: -> # {{{
                                # prepare
                                me = @cfg.refresh
                                me.data = {} if not me.data
                                data = me.data
                                # initialize data
                                if not data.boxes
                                    data.boxes = @cfg.node.find '.box'
                                    data.boxes.addClass 'attached'
                                # initialize 3d-slide effect (rotation)
                                # {{{
                                if not data.slide
                                    # determine indexes
                                    a = @cfg.nav.current or 0
                                    b = data.boxes.length - 1
                                    c =
                                        if a > 0 then a - 1 else b # left
                                        if a < b then a + 1 else 0 # right
                                    # get boxes
                                    b =
                                        data.boxes.eq c.0
                                        data.boxes.eq a
                                        data.boxes.eq c.1
                                    # define stage 1 parameters
                                    c =
                                        # left slide
                                        [
                                            # boxes
                                            [b.0, b.1, b.2]
                                            # transform origin
                                            ['100% 100%' '0% 0%' '0% 0%']
                                        ]
                                        # right slide
                                        [
                                            [b.2, b.1, b.0]
                                            ['0% 0%' '100% 100%' '100% 100%']
                                        ]
                                    # create effect
                                    data.slide = c.map (param) ->
                                        # prepare
                                        box = param.0
                                        transform = param.1
                                        deep = -(b.1.innerWidth!) / 5
                                        duration = [5, 30]
                                        # create timeline
                                        c = new TimelineLite {
                                            paused: true
                                        }
                                        # step 0
                                        # initital state
                                        c.set box.0, {
                                            transformOrigin: transform.0
                                            zIndex: 3
                                            visibility: true
                                        }, 0
                                        c.set box.1, {
                                            transformOrigin: transform.1
                                            rotationY: 30
                                            x: '100%'
                                            zIndex: 2
                                            visibility: true
                                        }, 0
                                        # step 1
                                        # detach transition
                                        c.to box, duration.0, {
                                            className: '+=detached'
                                        }, 0
                                        c.addLabel 's1'
                                        # step 2
                                        # rotate transition
                                        c.to box.0, duration.1, {
                                            rotationY: -60
                                            x: '-100%'
                                            z: deep
                                        }, 's1'
                                        c.to box.1, duration.1, {
                                            rotationY: 0
                                            x: '0%'
                                            z: deep
                                        }, 's1'
                                        # done
                                        c
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
                                    duration: 0.6
                                    tween:
                                        scale: 1
                                        ease: Back.easeOut
                                }
                            # }}}
                            hide: # {{{
                                {
                                    duration: 0.6
                                    tween:
                                        scale: 0
                                        ease: Back.easeIn
                                }
                                ...
                            # }}}
                            attach:
                                click:
                                    ['.button' 'nav']
                                    ...
                        title:
                            'Главное меню'
                            'Меню'
                        # template data
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
                                        name: 'Документы'
                                    }
                            }
                    # }}}
                    address: # {{{
                        cfg:
                            refresh: ->
                                true
                        title:
                            'Картотека адресов'
                            'Адрес'
                        tabs: [
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
                        ]
                    # }}}
                    config: # {{{
                        title:
                            'Настройки'
                            'Настр'
                    # }}}
                # }}}
                header: # {{{
                    cfg:
                        refresh: ->
                            @title.node.html @title.text
                            true
                    title:
                        node: null
                        text: ''
                    buttons:
                        b1:
                            node: null      # w3ui node
                            icon: ''        # svg icon
                            index: -1       # list index
                            list: null      # captions list
                        b2:
                            node: null
                            icon: ''
                            index: -1
                            list: null
                # }}}
                console: # {{{
                    cfg:
                        render: true
                        attach: true
                        init: ->
                            # modify show tween
                            @cfg.show.1.tween.className = @cfg.nav.id
                            true
                        resize: ->
                            # invalidate data
                            @cfg.data = {}
                            # refresh
                            @cfg.refresh.apply @
                        refresh: ->
                            # delegate
                            a = @cfg.nav.id
                            return @[a].refresh.apply @, [@cfg.data] if @[a].refresh
                            # done
                            true
                        show: # {{{
                            {
                                duration: 0
                                tween:
                                    visibility: 'visible'
                            }
                            {
                                duration: 0.4
                                tween:
                                    className: ''
                                    ease: Power3.easeOut
                            }
                        # }}}
                        hide: # {{{
                            {
                                duration: 0.4
                                tween:
                                    className: ''
                                    ease: Power3.easeIn
                            }
                            ...
                        # }}}
                    menu:
                        attach:
                            mouseover:
                                ['.carousel .button.left'  'left']
                                ['.carousel .button.right' 'right']
                            mouseout:
                                ['.carousel .button.left'  'left']
                                ['.carousel .button.right' 'right']
                            click:
                                ['.carousel .button.left'  'left']
                                ['.carousel .button.right' 'right']
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
                                data.node = @cfg.node.find '.carousel'
                                data.list = @cfg.node.find '.data .item'
                                data.time = @cfg.show.1.duration
                            if not data.box
                                data.box = data.node.find '.item'
                                data.btn = data.node.find '.button'
                            # initialize hover effect
                            # {{{
                            if not data.hover
                                # prepare
                                a = data.box
                                b = data.btn
                                # for left and right nodes
                                c = [0 2].map (index) ->
                                    # create timeline
                                    c = new TimelineLite {
                                        paused: true
                                        data: a.eq index
                                    }
                                    c.to [a[index], b[index], a.1, b.1], data.time, {
                                        className: '+=hover'
                                    }
                                    # done
                                    c
                                # save
                                data.hover = c
                            # }}}
                            # initialize slide effect
                            # {{{
                            if not data.slide
                                # prepare data
                                # determine active node index
                                a = @cfg.context.cfg.nav.current or 0
                                b = data.list.length - 1
                                # determine indexes of new elements
                                # that may appear
                                c =
                                    # from left
                                    if a > 1
                                        then a - 2
                                        else a - 1 + b
                                    # from right
                                    if a + 2 <= b
                                        then a + 2
                                        else a + 1 - b
                                # get boxes
                                a =
                                    data.list.eq c.0 .clone!
                                    data.list.eq c.1 .clone!
                                # get buttons
                                b =
                                    a.0.find '.button'
                                    a.1.find '.button'
                                # combine them
                                c =
                                    [a.0, b.0]
                                    [a.1, b.1]
                                # define classes
                                # final state
                                a =
                                    ['item' 'button left']
                                    ['item active' 'button center']
                                    ['item' 'button right']
                                # removal state
                                b = [['item hidden' 'button hidden']]
                                # combine it
                                a =
                                    a ++ b  # +left -right
                                    b ++ a  # -left +right
                                # combine both classes and nodes
                                a = a.map (side, direction) ->
                                    a = side.map (item, index) ->
                                        # new element
                                        if direction == 0 and index == 0 or
                                           direction == 1 and index == 3
                                            # done
                                            return [
                                                [c[direction].0, item.0]
                                                [c[direction].1, item.1]
                                            ]
                                        # current elements
                                        index = index - 1 if not direction
                                        a =
                                            data.box.eq index
                                            data.btn.eq index
                                        return [
                                            [a.0, item.0]
                                            [a.1, item.1]
                                        ]
                                # create effects
                                data.slide = a.map (side, direction) ->
                                    a = new TimelineLite {
                                        paused: true
                                        onStart: !->
                                            # add new node
                                            if direction
                                                data.node.append c.1.0
                                            else
                                                data.node.prepend c.0.0
                                        onComplete: !->
                                            # cleanup inline styles
                                            side.forEach (item) !->
                                                item.0.0.prop 'style', ''
                                                item.1.0.prop 'style', ''
                                            # remove node
                                            b = if direction
                                                then 0
                                                else side.length - 1
                                            side[b].0.0.remove!
                                            # invalidate current data
                                            delete data.box
                                            delete data.hover
                                            delete data.slide
                                    }
                                    # add tweens
                                    side.forEach (item) !->
                                        # container
                                        a.to item.0.0, data.time, {
                                            className: item.0.1
                                        }, 0
                                        # button
                                        a.to item.1.0, data.time, {
                                            className: item.1.1
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
                # check root
                return obj if not id
                # check root child
                return obj[id] if obj[id] and obj[id].cfg
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
                        return v[id] if v[id] and v[id].cfg
                        # add to stack
                        a.push v
                # not found
                return null
            # }}}
        }
        # }}}
        ###
        init: (id = '', parent = null, level = 0, namespace = '', templ) -> # {{{
            # get node
            if not (a = @skel[id]) or not b = a.cfg
                console.log 'getting of "'+id+'" failed'
                return false
            # prepare data
            id = b.id if not id
            namespace += id.charAt 0 .toUpperCase! + id.slice 1
            if not templ
                templ = $ 'template'
                templ = $ templ.0.content
            # initialize
            b.id        = id
            b.parent    = parent
            b.root      = parent.cfg.root if parent
            b.level     = level
            b.nav       = M.nav[level]
            b.namespace = namespace
            b.render    = w3ui.PARTIAL a, @render if b.render
            b.attach    = w3ui.PARTIAL a, @attach, b.attach if b.attach
            b.template  = templ
            b.data      = {}
            # recurse to children
            for own b,c of a when b != 'cfg' and c and c.cfg
                return false if not @init b, a, level + 1, namespace, templ
            # complete
            true
        # }}}
        walk: (id, direction, func, onComplete) -> # {{{
            # prepare
            # get start node
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
                return walk.every (node) -> func.apply node
            # walk
            # internal functions
            if onComplete
                # create thread
                a = []
                for b in walk when b.cfg[func]
                    # create chain unit
                    a.push let node = b
                        -> node.cfg[func].apply node
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
                then node.cfg[func].apply node
                else true
        # }}}
        render: (id = @cfg.nav.id) -> # {{{
            # initialize
            if not @cfg.node
                @cfg.node = w3ui '#'+@cfg.id
            # check
            return false if not @cfg.node
            return true  if not id
            # determine node type and select data
            a = @cfg.parent
            if not a or a.cfg.nav.id == @cfg.id
                # primary
                b = id
                c = @[b]
            else
                # adjacent
                b = ''
                # get context of the primary node
                return true if not a = a[a.cfg.nav.id][id]
                # save context
                @cfg.context = a
                # generate data
                c = @[id].render.apply a
            # determine template id
            a = @
            while a.cfg.parent and a.cfg.level
                id = a.cfg.id + '-' + id
                a  = a.cfg.parent
            # select template
            a = @cfg.template.find '#t-'+id
            if not a or not a.length
                # no template
                return true
            a = a.0.innerHTML
            # construct HTML
            a = Mustache.render a, c
            # inject
            @cfg.node.html a
            # initialize child
            c.cfg.node = w3ui '#'+b if b
            # done
            true
        # }}}
        attach: (events) -> # {{{
            # check
            return true if not @cfg.node
            if events == true
                # adjacent event source
                # extract
                if not (a = @cfg.nav.id) or not (b = @[a])
                    return true
                # get events
                events = b.attach
            # assemble events
            e = []
            for own a,b of events
                # event name
                a = a + '.' + @cfg.namespace
                # event targets
                for d in b
                    # get node and data
                    c = $ '#'+@cfg.id+' '+d.0
                    d = d.1
                    # check
                    continue if not c or not c.length
                    # add
                    e.push [a, c, d]
            # check
            return true if not e.length
            # define handler
            # bind it to current node
            d = w3ui.PARTIAL @, P.event
            # attach
            for [a, b, c] in e
                b.on a, null, c, d
            # define detach
            @cfg.detach = ->
                # detach
                for [a, b, c] in e
                    b.off a
                # done
                delete @detach
                true
            # done
            true
        # }}}
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
            $ window .on 'resize', !-> P.resize!
            # done
            true
        # }}}
        construct: (id = '') !-> # {{{
            # get root of construction
            return if not node = V.skel[id]
            # local lock
            busy = false
            # start thread
            w3ui.THREAD [
                ->
                    # wait
                    return false if P.construct.busy
                    # lock global
                    P.construct.busy = true
                    # detach events
                    if not V.walk id, false, 'detach'
                        console.log 'detach failed'
                        delete P.construct.busy
                        return null
                    # hide
                    # create main timeline
                    a = new TimelineLite {
                        paused: true
                        onComplete: -> busy := false
                    }
                    V.walk id, false, ->
                        # check node
                        return true if not node = @cfg.node
                        # create effect timeline
                        b = new TimelineLite {paused: true}
                        # add tweens
                        @cfg.hide and @cfg.hide.forEach (c) ->
                            b.to node, c.duration, c.tween
                        # add final tween
                        b.set node, {visibility: 'hidden'}
                        # insert at the beginning of the main
                        # play to remove paused state
                        a.add b.play!, 0
                        # done
                        true
                    # lock
                    busy := true
                    # start animation
                    a.play!
                    # continue
                    true
                ->
                    # wait
                    not busy
                ->
                    # cleanup
                    V.walk id, false, ->
                        # remove link
                        if @cfg.node and (a = @cfg.level) and @cfg.id != M[a - 1]
                            @cfg.node = null
                        # done
                        true
                    # render new content
                    a = ['render' 'init' 'resize'].every (f) ->
                        V.walk id, true, f
                    # check the result
                    if not a
                        console.log 'render sequence failed'
                        delete P.construct.busy
                        return null
                    # before new elements are shown,
                    # they should be at a hidden state
                    V.walk id, true, ->
                        # check node
                        return true if not node = @cfg.node
                        # hide
                        node.style.visibility = 'hidden'
                        true
                    # show
                    # create main timeline
                    a = new TimelineLite {
                        paused: true
                        onComplete: -> busy := false
                    }
                    # add first label
                    b = 'lev'+node.cfg.level
                    a.addLabel b, 0
                    # nest effects
                    V.walk id, true, ->
                        # check node
                        return true if not node = @cfg.node
                        # create effect timeline
                        tl = new TimelineLite {
                            paused: true
                        }
                        # add tweens
                        @cfg.show and @cfg.show.forEach (a) ->
                            tl.to node, a.duration, a.tween
                        # add final tween
                        tl.set node, {visibility: 'visible'}
                        # check label
                        if b != 'lev'+@cfg.level
                            # we dont check if it's already exist because
                            # the walk sequence is aligned properly
                            # change
                            b := 'lev'+@cfg.level
                            # append new label to the end
                            a.addLabel b
                        # insert timeline
                        # play it to remove paused state
                        a.add tl.play!, b
                        # done
                        true
                    # lock
                    busy := true
                    # start animation
                    a.play!
                    # continue
                    true
                ->
                    # wait
                    not busy
                ->
                    # refresh
                    if not V.walk id, true, 'refresh'
                        console.log 'refresh failed'
                        delete P.construct.busy
                        return null
                    # finish
                    V.walk id, false, 'finit'
                    # attach event handlers
                    if not V.walk id, true, 'attach'
                        console.log 'attach failed'
                    # unlock
                    delete P.construct.busy
                    true
            ]
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
                f = w3ui.PARTIAL @, me
                me.timer = window.setTimeout f, 250
            # resize
            else if not V.walk '', true, 'resize'
                console.log 'resize failed'
        # }}}
        event: (event) -> # {{{
            # check
            return false if not @cfg
            # prepare
            me  = @
            cfg = me.cfg
            nav = cfg.nav
            # prepare data storage
            cfg.attach.data = {} if not cfg.attach.data
            a = cfg.node.data
            a[nav.id] = {} if not a[nav.id]
            data = a[nav.id]
            # handle event
            switch cfg.id
            | 'menu' =>
                # change model
                #M.2 = event.target.className
                # construct
                #P.construct 'view'
                true
            | 'console' =>
                switch nav.id
                | 'menu' =>
                    # {{{
                    # prepare
                    direction = if event.data == 'left'
                        then 0
                        else 1
                    # check action type
                    switch event.type
                    | 'mouseover' =>
                        # activate hover effect
                        # get effect
                        a = V.skel.console.cfg.data.hover
                        # play
                        a[direction].play!
                    | 'mouseout' =>
                        # deactivate hover effect
                        # get effect
                        a = V.skel.console.cfg.data.hover
                        # reverse play
                        a[direction].reverse!
                    | 'click' =>
                        # get effects
                        a = V.skel.console.cfg.data.slide
                        # create timeline
                        t = new TimelineLite {
                            paused: true
                            onStart: !->
                                # detach events
                                cfg.detach!
                            onComplete: !->
                                # change model state
                                # determine current
                                c = cfg.level + 1
                                a = M.nav[c].current or 0
                                # determine new current
                                b = cfg.context.data.length - 1
                                if direction
                                    b = if a < b
                                        then a + 1
                                        else 0
                                else
                                    b = if a > 0
                                        then a - 1
                                        else b
                                # change
                                M.nav[c].current = b
                                # refresh
                                V.walk 'wa', true, 'refresh', ->
                                    # reattach events
                                    cfg.attach!
                        }
                        # add effects
                        t.add a[direction].play!
                        # launch
                        t.play!
                        return true
                        # menu slide
                        if not data.menu
                            data.menu = V.skel['menu'].cfg.node.find '.box'
                            data.list = cfg.node.find '.data .item'
                            data.node = cfg.node.find '.carousel'
                        #a = V.skel.menu.cfg.refresh.data.slide
                        #a.0.play!
                        # get active and new active box
                        # {{{
                        /***
                        do ->
                            a = data.menu.eq data.current.1
                            b = data.menu.eq data.current.0
                            c = new TimelineLite {
                                paused: true
                            }
                            d = a.innerWidth!
                            d = -d / 5
                            duration = 10
                            c.set a, {
                                transformOrigin: '100% 100%'
                                className: '+=selected'
                            }, 0
                            c.set b, {
                                transformOrigin: '0% 0%'
                                rotationY: 30
                                x: '100%'
                                className: '+=selected cube'
                            }, 0
                            c.to [a, b], duration / 5, {
                                className: '+=cube'
                            }, 0
                            c.addLabel 'h1'
                            c.to a, duration, {
                                rotationY: -60
                                x: '-100%'
                                z: d
                            }, 'h1'
                            c.to b, duration, {
                                rotationY: 0
                                x: '0%'
                                z: d
                            }, 'h1'
                            c.play!
                        @keyframes rotateCubeLeftOut {
                            0% { }
                            50% {
                                transform: translateX(-50%) translateZ(-200px) rotateY(-45deg);
                            }
                            100% {
                                opacity: .3;
                                transform: translateX(-100%) rotateY(-90deg);
                            }
                        }
                        @keyframes rotateCubeLeftIn {
                            0% {
                                opacity: .3;
                                transform: translateX(100%) rotateY(90deg);
                            }
                            50% {
                                transform: translateX(50%) translateZ(-200px) rotateY(45deg);
                            }
                        }
                        @keyframes rotateCubeRightOut {
                            0% { }
                            50% {
                                transform: translateX(50%) translateZ(-200px) rotateY(45deg);
                            }
                            100% {
                                opacity: .3;
                                transform: translateX(100%) rotateY(90deg);
                            }
                        }
                        @keyframes rotateCubeRightIn {
                            0% {
                                opacity: .3;
                                transform: translateX(-100%) rotateY(-90deg);
                            }
                            50% {
                                transform: translateX(-50%) translateZ(-200px) rotateY(-45deg);
                            }
                        }
                        /***/
                        # }}}
                    # }}}
            # done
            true
        # }}}
    # }}}
    ###
    P.init! if M and V and P
#######

