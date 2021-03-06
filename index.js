// Generated by LiveScript 1.5.0
'use strict';
w3ui && w3ui.app({
  M: {
    navDefault: ['wa', 'view', 'menu']
  },
  V: {
    ui: {
      cfg: {
        id: '',
        node: null,
        parent: null,
        context: null,
        data: {},
        level: 0,
        nav: null,
        el: null,
        render: true
      },
      wa: {
        cfg: {
          fontSizeMin: 0,
          fontSizeMax: 0,
          init: function(){
            this.cfg.fontSizeMin = parseInt(this.cfg.node.style.fSizeMin);
            this.cfg.fontSizeMax = parseInt(this.cfg.node.style.fSizeMax);
            return true;
          }
        },
        view: {
          cfg: {
            render: true,
            turn: {
              on: [
                {
                  to: {
                    className: '+=color',
                    opacity: 0,
                    scale: 0.6
                  }
                }, {
                  duration: 0.2,
                  to: {
                    opacity: 0.5
                  }
                }, {
                  duration: 0.6,
                  to: {
                    opacity: 1,
                    scale: 1
                  }
                }, {
                  position: '-=0.1',
                  duration: 0.3,
                  to: {
                    className: '-=color'
                  }
                }
              ],
              off: [
                {
                  duration: 0.2,
                  to: {
                    className: '+=color',
                    scale: 0.9
                  }
                }, {
                  duration: 0.8,
                  to: {
                    scale: 1,
                    opacity: 0
                  }
                }
              ]
            }
          },
          menu: {
            cfg: {
              render: true,
              init: function(){
                var c, d, a, b;
                c = this.cfg;
                d = this.cfg.data;
                if (!d.menu) {
                  d.menu = c.node.query('.box');
                  d.time = c.show[1].duration;
                }
                while ((a = c.nav.current) === undefined) {
                  c.nav.current = 0;
                }
                while (!(b = c.nav.currentItem)) {
                  c.nav.currentItem = this.data.map(fn$);
                }
                d.menu[a].style.visibility = 'visible';
                return true;
                function fn$(){
                  return 0;
                }
              },
              finit: function(){
                w3ui.clearObject(this.cfg.data);
                return true;
              },
              refresh: function(){
                var cfg, data, a, i$, to$, b, c, d, e;
                cfg = this.cfg;
                data = this.cfg.data;
                if (!data.box) {
                  a = cfg.nav.current;
                  data.box = data.menu[a];
                  data.btn = data.box.query('.button');
                  for (i$ = 0, to$ = data.btn.length - 1; i$ <= to$; ++i$) {
                    b = i$;
                    data.btn[b].dataset.num = b;
                    data.btn[b].dataset.id = this.data[a].list[b].id;
                  }
                  a = cfg.nav.currentItem[a];
                  data.btn[a]['class'].add('active');
                }
                if (!data.slide) {
                  a = cfg.nav.current || 0;
                  b = data.menu.length - 1;
                  c = [a > 0 ? a - 1 : b, a < b ? a + 1 : 0];
                  a = [[data.menu[a].node, data.menu[c[0]].node], [data.menu[a].node, data.menu[c[1]].node]];
                  c = [['0%', '100%', '-100%', '0%'], ['0%', '-100%', '100%', '0%']];
                  data.slide = a.map(function(a, index){
                    var b;
                    b = new TimelineLite({
                      paused: true,
                      data: {
                        complete: function(){
                          delete data.slide;
                        }
                      }
                    });
                    b.set(a, {
                      transformOrigin: '0% 50%',
                      visibility: 'visible'
                    });
                    b.addLabel('s1');
                    b.fromTo(a[0], data.time, {
                      x: c[index][0]
                    }, {
                      x: c[index][1]
                    }, 's1');
                    b.fromTo(a[1], data.time, {
                      x: c[index][2]
                    }, {
                      x: c[index][3]
                    }, 's1');
                    b.set(a[0], {
                      visibility: 'hidden'
                    });
                    b.set(a[1], {
                      visibility: 'visible'
                    });
                    return b;
                  });
                }
                if (!data.drag) {
                  a = cfg.el.console.cfg.data.slide;
                  b = data.slide;
                  c = [
                    new TimelineLite({
                      paused: true,
                      ease: Power3.easeInOut
                    }), new TimelineLite({
                      paused: true,
                      ease: Power3.easeInOut
                    })
                  ];
                  d = function(){
                    var a, b;
                    a = 'drag';
                    b = !cfg.node['class'].has(a);
                    cfg.node['class'].toggle(a, b);
                  };
                  e = function(index){
                    return function(){
                      cfg.node['class'].remove('drag');
                      a[index].data.complete();
                      b[index].data.complete();
                      delete data.box;
                      delete data.drag;
                    };
                  };
                  c[0].add(d);
                  c[0].add(a[0].play(), 0);
                  c[0].add(b[0].play(), 0);
                  c[0].add(e(0));
                  c[1].add(d);
                  c[1].add(a[1].play(), 0);
                  c[1].add(b[1].play(), 0);
                  c[1].add(e(1));
                  data.drag = c;
                }
                return true;
              },
              show: [
                {
                  to: {
                    backgroundColor: 'transparent',
                    scale: 0
                  }
                }, {
                  duration: 0.8,
                  to: {
                    scale: 1,
                    clearProps: 'backgroundColor',
                    ease: Back.easeOut
                  }
                }
              ],
              hide: [{
                duration: 0.8,
                to: {
                  scale: 0,
                  ease: Power3.easeIn
                }
              }],
              attach: [
                {
                  event: 'click',
                  el: '.button'
                }, {
                  event: 'pointerover',
                  el: '.button'
                }, {
                  event: 'pointerdown',
                  el: ''
                }, {
                  event: 'pointermove',
                  el: ''
                }, {
                  event: 'pointerup',
                  el: ''
                }, {
                  event: 'keydown',
                  el: document,
                  keys: ['ArrowUp', 'ArrowDown']
                }
              ]
            },
            title: 'Главное меню',
            config: true,
            data: [
              {
                id: 'card',
                name: 'Картотека',
                list: [
                  {
                    id: 'address',
                    name: 'Адреса'
                  }, {
                    id: 'counterparty',
                    name: 'Контрагенты'
                  }
                ]
              }, {
                id: 'income',
                name: 'Входящие',
                list: [
                  {
                    id: 'accrual',
                    name: 'Начисления'
                  }, {
                    id: 'payment',
                    name: 'Оплата'
                  }, {
                    id: 'storno',
                    name: 'Сторно'
                  }
                ]
              }, {
                id: 'outcome',
                name: 'Исходящие',
                list: [
                  {
                    id: 'calc',
                    name: 'Расчеты'
                  }, {
                    id: 'document',
                    name: 'Отчеты'
                  }
                ]
              }
            ]
          },
          address: {
            cfg: {
              refresh: function(){
                return true;
              },
              show: [
                {
                  duration: 0,
                  to: {
                    scale: 0
                  }
                }, {
                  duration: 0.8,
                  to: {
                    scale: 1,
                    ease: Back.easeOut
                  }
                }
              ],
              hide: [{
                duration: 0.8,
                to: {
                  scale: 0,
                  ease: Back.easeIn
                }
              }]
            },
            title: 'Адреса',
            config: true,
            tab: [
              {
                id: 'a0',
                name: 'квартира'
              }, {
                id: 'a1',
                name: 'дом'
              }, {
                id: 'a2',
                name: 'улица'
              }, {
                id: 'a3',
                name: 'район'
              }, {
                id: 'a4',
                name: 'город'
              }
            ]
          },
          payment: {
            cfg: {
              refresh: function(){
                return true;
              }
            },
            title: 'Оплата'
          },
          config: {
            cfg: {
              init: function(){
                return true;
              },
              refresh: function(){
                return true;
              }
            },
            title: 'Конфигурация',
            current: function(){
              return this.cfg.nav.current;
            }
          }
        },
        header: {
          cfg: {
            render: false,
            init: function(){
              var cfg, dat, ctx, id, a, b, c, d;
              cfg = this.cfg;
              dat = cfg.data;
              ctx = cfg.context;
              id = ctx ? ctx.cfg.id : '';
              if (!dat.title) {
                dat.title = cfg.node.query('.title');
                dat.mode = cfg.node.query('.mode .button');
                dat.config = cfg.node.query('.config .button');
              }
              cfg.node['class'].clear('on');
              cfg.node['class'].add(id);
              dat.title.$text = ctx && ctx.title ? ctx.title : '';
              a = id === 'menu' ? 'return' : 'menu';
              b = dat.mode;
              b.$text = this.mode[a];
              b.$icon = cfg.template.querySelector('#' + a).innerHTML;
              if (b.$anim) {
                b.$anim.kill();
              }
              b.prop.dataId = 'mode';
              a = id === 'config' ? 'close' : 'config';
              b = dat.config;
              b.$text = this.config[a];
              b.$icon = cfg.template.querySelector('#' + a).innerHTML;
              if (b.$anim) {
                b.$anim.kill();
              }
              b.prop.dataId = 'config';
              a = [id === 'config', id !== 'config' && (!ctx || !ctx.config)];
              b = [dat.mode.node, dat.config.node];
              c = [];
              if (a[0]) {
                c.push(b[0]);
              }
              if (a[1]) {
                c.push(b[1]);
              }
              d = [];
              if (!a[0]) {
                d.push(b[0]);
              }
              if (!a[1]) {
                d.push(b[1]);
              }
              a = cfg.show[0].group;
              a[0].node = dat.title.node;
              a[2].node = c;
              a[3].node = b;
              cfg.show[4].node = dat.title.node;
              cfg.show[5].node = b;
              cfg.hide[1].node = b;
              cfg.hide[2].node = dat.title.node;
              cfg.turn[1].node = dat.title.node;
              cfg.turn[2].node = b;
              cfg.turn[2].group[2].node = d;
              dat.resizeAnim = w3ui.GSAP.queue(cfg.node, [cfg.hide[1], cfg.show[5]]);
              return true;
            },
            resize: function(noAnimation){
              var cfg, dat, a, c, b;
              noAnimation == null && (noAnimation = false);
              cfg = this.cfg;
              dat = this.cfg.data;
              a = dat.title.box.fontSize(dat.title.$text);
              c = cfg.el.wa.cfg;
              b = [c.fontSizeMin, c.fontSizeMax];
              if (a < b[0]) {
                a = 0;
              }
              if (a > b[1]) {
                a = b[1];
              }
              c.node.style.fSize0 = a + 'px';
              a = dat.resizeAnim.isActive();
              if (a) {
                return true;
              }
              dat.useIcon = [dat.mode, dat.config].some(function(a){
                var b;
                if (a.$text && !a['class'].has('disabled')) {
                  b = a.box.textMetrics(a.$text).width;
                  if (a.box.innerWidth < b) {
                    return true;
                  }
                }
                return false;
              });
              b = dat.mode['class'].has('icon');
              if (noAnimation || !(!dat.useIcon !== !b && (dat.useIcon || b))) {
                return true;
              }
              return dat.resizeAnim.play(0);
            },
            show: [
              {
                group: [
                  {
                    node: null,
                    to: {
                      opacity: 0,
                      scale: 0
                    }
                  }, function(){
                    var a;
                    a = this.cfg.data.title;
                    a.html = a.$text;
                  }, {
                    node: null,
                    to: {
                      className: '+=disabled'
                    }
                  }, {
                    node: null,
                    to: {
                      className: '-=hovered',
                      scale: 0
                    }
                  }
                ]
              }, {
                position: 'beg',
                duration: 0.4,
                to: {
                  className: 'on',
                  opacity: 1,
                  ease: Power3.easeOut
                }
              }, function(){
                this.cfg.resize.call(this, true);
              }, 'show', {
                position: 'show',
                node: null,
                duration: 0.6,
                to: {
                  opacity: 1,
                  scale: 1,
                  ease: Back.easeOut
                }
              }, {
                position: 'show',
                node: null,
                group: [
                  function(){
                    var a, b;
                    a = this.cfg.data;
                    b = a.useIcon ? '$icon' : '$text';
                    a.mode.html = a.mode[b];
                    a.config.html = a.config[b];
                    a.mode.$svg = a.mode.query('svg');
                    a.config.$svg = a.config.query('svg');
                    a.mode['class'].toggle('icon', a.useIcon);
                    a.config['class'].toggle('icon', a.useIcon);
                  }, {
                    duration: 0.4,
                    to: {
                      scale: 1,
                      ease: Back.easeOut
                    }
                  }
                ]
              }
            ],
            hide: [
              'beg', {
                position: 'beg',
                duration: 0.4,
                node: null,
                to: {
                  scale: 0,
                  ease: Power3.easeIn
                }
              }, {
                position: 'beg',
                duration: 0.4,
                node: null,
                to: {
                  scale: 0,
                  opacity: 0,
                  ease: Power3.easeIn
                }
              }, {
                duration: 0.4,
                to: {
                  className: '',
                  ease: Power3.easeIn
                }
              }
            ],
            turn: [
              'beg', {
                position: 'beg',
                node: null,
                group: [
                  {
                    duration: 0.4,
                    to: {
                      opacity: 0,
                      scale: 0.6,
                      ease: Power2.easeIn
                    }
                  }, function(){
                    var a;
                    a = this.cfg.data;
                    a.title.html = a.title.$text;
                  }, {
                    duration: 0.4,
                    to: {
                      opacity: 1,
                      scale: 1,
                      ease: Back.easeOut
                    }
                  }
                ]
              }, {
                position: 'beg',
                node: null,
                group: [
                  {
                    duration: 0.2,
                    to: {
                      className: '-=hovered',
                      opacity: 0,
                      scale: 0.8,
                      ease: Power2.easeIn
                    }
                  }, function(){
                    var d, a, b, c;
                    d = this.cfg.data;
                    a = d.mode;
                    b = d.config;
                    c = d.useIcon ? '$icon' : '$text';
                    a.html = a[c];
                    b.html = b[c];
                    a.$svg = a.query('svg');
                    b.$svg = b.query('svg');
                    a['class'].toggle('icon', d.useIcon);
                    b['class'].toggle('icon', d.useIcon);
                  }, {
                    duration: 0.4,
                    node: null,
                    to: {
                      opacity: 1,
                      scale: 1,
                      ease: Power2.easeOut
                    }
                  }
                ]
              }
            ],
            attach: [
              {
                event: 'pointerover',
                el: '.button'
              }, {
                event: 'pointerout',
                el: '.button'
              }, {
                event: 'click',
                el: '.mode .button',
                id: 'mode'
              }, {
                event: 'click',
                el: '.config .button',
                id: 'config'
              }
            ]
          },
          mode: {
            'return': 'возврат',
            menu: 'меню'
          },
          config: {
            close: 'закрыть',
            config: 'настройки'
          }
        },
        console: {
          cfg: {
            render: true,
            attach: true,
            init: function(){
              var cfg, id;
              cfg = this.cfg;
              id = cfg.nav.id;
              cfg.node['class'].clear('on');
              cfg.node['class'].add(id);
              return true;
            },
            resize: function(){
              w3ui.clearObject(this.cfg.data);
              return this.cfg.refresh.call(this);
            },
            refresh: function(){
              var a, b;
              a = this.cfg.nav.id;
              b = this[a];
              if (!b || !b.refresh) {
                return true;
              }
              return b.refresh.call(this);
            },
            show: [{
              duration: 0.8,
              to: {
                className: '+=on',
                opacity: 1,
                ease: Power3.easeOut
              }
            }],
            hide: [{
              duration: 0.6,
              to: {
                className: '',
                opacity: 0,
                ease: Power3.easeIn
              }
            }],
            turn: {
              off: [
                {
                  duration: 0.4,
                  to: {
                    opacity: 0
                  }
                }, {
                  to: {
                    display: 'none'
                  }
                }
              ],
              on: [
                {
                  position: 0.4,
                  label: 'beg'
                }, {
                  position: 'beg',
                  to: {
                    opacity: 0,
                    scale: 0.5,
                    clearProps: 'display'
                  }
                }, {
                  position: 'beg',
                  duration: 0.4,
                  to: {
                    opacity: 1,
                    scale: 1
                  }
                }
              ]
            }
          },
          menu: {
            attach: [
              {
                event: 'pointerover',
                el: '.button.left',
                id: 'left'
              }, {
                event: 'pointerover',
                el: '.button.right',
                id: 'right'
              }, {
                event: 'pointerout',
                el: '.button.left',
                id: 'left'
              }, {
                event: 'pointerout',
                el: '.button.right',
                id: 'right'
              }, {
                event: 'click',
                el: '.button.left',
                id: 'left',
                delayed: true
              }, {
                event: 'click',
                el: '.button.right',
                id: 'right',
                delayed: true
              }, {
                event: 'keydown',
                el: document,
                keys: ['ArrowLeft', 'ArrowRight', 'Enter'],
                delayed: true
              }
            ],
            render: function(){
              var ctx, a, b, c, d;
              ctx = this.cfg.context;
              a = ctx.data;
              b = ctx.cfg.nav.current || 0;
              c = a.length - 1;
              d = this.cfg.data;
              d.list = a.map(function(a){
                return {
                  id: a.id,
                  name: a.name
                };
              });
              d.current = a[b].name;
              d.prev = b
                ? a[b - 1].name
                : a[a.length - 1].name;
              d.next = b === c
                ? a[0].name
                : a[b + 1].name;
              return d;
            },
            refresh: function(){
              var data, a, b, c, main;
              data = this.cfg.data;
              if (!data.node) {
                data.node = this.cfg.node.query('.menu');
                data.time = this.cfg.show[0].duration;
              }
              if (!data.box) {
                data.box = data.node.query('.item');
                data.btn = data.node.query('.button');
              }
              if (!data.hover) {
                a = data.box;
                b = data.btn;
                c = [[a[1].node, b[1].node, a[2].node, b[2].node], [a[3].node, b[3].node, a[2].node, b[2].node]];
                data.hover = c.map(function(c){
                  var d;
                  d = new TimelineLite({
                    paused: true,
                    ease: Power2.easeOut
                  });
                  d.add((function(a, b){
                    return function(){
                      a['class'].remove('hover');
                      b['class'].remove('hover');
                    };
                  }.call(this, a, b)));
                  d.to(c, data.time, {
                    className: '+=hover'
                  });
                  return d;
                });
              }
              if (!data.slide) {
                main = this.cfg.context;
                a = main.cfg.nav.current || 0;
                b = main.data.length - 1;
                c = [
                  a > 1
                    ? a - 2
                    : a - 1 + b, a + 2 <= b
                    ? a + 2
                    : a + 1 - b
                ];
                data.btn[0].html = main.data[c[0]].name;
                data.btn[4].html = main.data[c[1]].name;
                a = [data.box[0].clone(), data.box[4].clone()];
                data.slide = a.map(function(newBox, index){
                  var a, b;
                  a = new TimelineMax({
                    paused: true,
                    data: {
                      complete: function(){
                        var a;
                        a = data.node.child;
                        if (index) {
                          a.add(newBox);
                          a.remove(data.box[0]);
                        } else {
                          a.insert(newBox);
                          a.remove(data.box[4]);
                        }
                        delete data.box;
                        delete data.hover;
                        delete data.slide;
                      }
                    }
                  });
                  if (index) {
                    b = [['+=hidden', '-=active', '+=active', '-=hidden'], ['+=hidden', 'button left', 'button center', '-=hidden']];
                  } else {
                    b = [['-=hidden', '+=active', '-=active', '+=hidden'], ['-=hidden', 'button center', 'button right', '+=hidden']];
                  }
                  a.to(data.box[index + 0].node, data.time, {
                    className: b[0][0]
                  }, 0);
                  a.to(data.box[index + 1].node, data.time, {
                    className: b[0][1]
                  }, 0);
                  a.to(data.box[index + 2].node, data.time, {
                    className: b[0][2]
                  }, 0);
                  a.to(data.box[index + 3].node, data.time, {
                    className: b[0][3]
                  }, 0);
                  a.to(data.btn[index + 0].node, data.time, {
                    className: b[1][0]
                  }, 0);
                  a.to(data.btn[index + 1].node, data.time, {
                    className: b[1][1]
                  }, 0);
                  a.to(data.btn[index + 2].node, data.time, {
                    className: b[1][2]
                  }, 0);
                  a.to(data.btn[index + 3].node, data.time, {
                    className: b[1][3]
                  }, 0);
                  return a;
                });
              }
              return true;
            }
          },
          address: {
            render: function(){
              return {};
            }
          },
          payment: {
            render: function(){
              return {};
            }
          }
        }
      },
      w3demo: {
        cfg: {
          empty: true
        },
        view: {
          cfg: {
            render: true
          },
          intro: {
            cfg: {
              empty: true
            },
            data: [{
              title: 'Документация w3ui',
              text: 'bla bla bla'
            }]
          },
          widget: {
            cfg: {
              init: function(){
                var a, b;
                a = this.cfg.nav.id;
                b = w3ui[a](this.cfg.node, this[a].options);
                this.cfg.data.widget = b;
                this.cfg.show = this.cfg.show.concat(b.animation.show);
                return true;
              },
              finit: function(){
                this.cfg.show = this.cfg.show.slice(0, 1);
                return true;
              },
              show: [{
                duration: 0.4,
                to: {
                  className: '+=show'
                }
              }]
            },
            accordion: {
              title: 'аккордеон',
              options: {
                panels: [
                  {
                    name: 'test1',
                    active: true,
                    val: 'text1'
                  }, {
                    name: 'test2',
                    val: [
                      {
                        name: 'test2-1',
                        val: 'text2-1'
                      }, {
                        name: 'test2-2',
                        val: 'text2-2'
                      }
                    ]
                  }, {
                    name: 'test3',
                    val: 'text3'
                  }
                ]
              }
            },
            slider: {
              title: 'слайдер'
            }
          }
        },
        sidebar: {
          cfg: {
            render: false,
            init: function(){
              return true;
            }
          }
        }
      }
    }
  },
  P: {
    react: function(M, V, P, event){
      var cfg, nav, dat, a, b, c, d, e, i$, ref$, len$, this$ = this;
      cfg = this.cfg;
      nav = this.cfg.nav;
      dat = event.data;
      switch (cfg.id) {
      case 'header':
        a = event.currentTarget.dataset.id;
        b = cfg.data[a];
        if (b.$anim) {
          b.$anim.kill();
        }
        switch (event.type) {
        case 'pointerover':
          if (cfg.data.useIcon) {
            b.$svg['class'].add('hovered');
          } else {
            b.$anim = TweenLite.to(b.node, 0.6, {
              className: '+=hovered',
              ease: Power3.easeOut
            });
          }
          break;
        case 'pointerout':
          if (cfg.data.useIcon) {
            b.$svg['class'].remove('hovered');
          } else {
            TweenLite.to(b.node, 0.4, {
              className: '-=hovered',
              ease: Power3.easeIn
            });
          }
          break;
        case 'click':
          b = nav.id;
          if (a === 'mode' && b === 'menu') {
            break;
          } else if (a === 'config') {
            if (b === 'config') {
              M[cfg.level] = M.nav[cfg.level + 1].current;
            } else {
              M[cfg.level] = 'config';
              M.nav[cfg.level + 1].current = b;
            }
          } else {
            M[cfg.level] = 'menu';
          }
          P.update();
        }
        break;
      case 'menu':
        !dat.change && (dat.change = function(active){
          var a, b;
          a = nav.current || 0;
          b = this$.data.length - 1;
          if (active) {
            a = a > 0 ? a - 1 : b;
          } else {
            a = a < b ? a + 1 : 0;
          }
          nav.current = a;
        });
        switch (event.type) {
        case 'pointerdown':
          a = document.elementFromPoint(event.pageX, event.pageY);
          if (a.className === 'button') {
            break;
          }
          event.stopPropagation();
          dat.swipe = event.pointerType !== 'mouse';
          dat.size = 0.5 * cfg.node.box.innerWidth;
          dat.x = event.pageX;
          dat.active = false;
          dat.drag = V.el.menu.cfg.data.drag;
          break;
        case 'pointermove':
          if (!dat.drag) {
            break;
          }
          event.stopPropagation();
          if ((a = event.pageX - dat.x) < 0) {
            b = [0, 1];
          } else {
            b = [1, 0];
          }
          if ((a = Math.abs(a)) < 0.1) {
            if (!dat.swipe) {
              break;
            }
            delete dat.drag;
            break;
          }
          c = b.map(function(index){
            return dat.drag[index];
          });
          a = a / dat.size;
          if (a > 0.99) {
            a = 0.99;
          }
          if (dat.swipe) {
            dat.change(b[0]);
            delete dat.drag;
            c[1].add(P.refresh);
            return c[1].play();
          }
          d = !dat.active || dat.active[0] !== b[0];
          e = d || Math.abs(a - c[1].progress()) > 0.001;
          if (d) {
            if (!c[0].paused()) {
              c[0].pause();
            }
            c[0].progress(0);
          }
          if (e) {
            if (!c[1].paused()) {
              c[1].pause();
            }
            c[1].progress(a);
          }
          dat.active = b;
          break;
        case 'pointerup':
          if (!dat.drag || dat.swipe) {
            break;
          }
          event.stopPropagation();
          if (!(a = dat.active)) {
            delete dat.drag;
            break;
          }
          b = dat.drag[a[1]].progress();
          if (b < 0.35) {
            dat.drag[a[1]].reverse();
            delete dat.drag;
            break;
          }
          dat.change(a[0]);
          a = dat.drag[a[1]];
          a.add(P.refresh);
          return a.play();
        case 'pointerover':
          if ((a = event.target.dataset.num) === undefined) {
            break;
          }
          event.stopPropagation();
          a = +a;
          nav.currentItem[nav.current] = a;
          cfg.data.btn['class'].toggle('active', function(el, index){
            return index === a;
          });
          true;
          break;
        case 'keydown':
          a = event.conf.keys.indexOf(event.key);
          if (a < 0) {
            break;
          }
          event.preventDefault();
          event.stopImmediatePropagation();
          b = nav.currentItem[nav.current];
          c = cfg.data.btn;
          if (a) {
            a = b < c.length - 1 ? b + 1 : 0;
          } else {
            a = b > 0
              ? b - 1
              : c.length - 1;
          }
          nav.currentItem[nav.current] = a;
          c['class'].toggle('active', function(el, index){
            return index === a;
          });
          break;
        case 'click':
          event.stopPropagation();
          a = cfg.level - 1;
          b = event.target.dataset.id;
          M[a] = b;
          P.update();
        }
        break;
      case 'console':
        switch (nav.id) {
        case 'menu':
          !dat.change && (dat.change = function(id){
            var c, a, b, d;
            c = cfg.level + 1;
            a = M.nav[c].current || 0;
            b = cfg.context.data.length - 1;
            if (id) {
              b = a < b ? a + 1 : 0;
            } else {
              b = a > 0 ? a - 1 : b;
            }
            M.nav[c].current = b;
            a = V.el.console.cfg.data.hover;
            b = V.el.menu.cfg.data.drag[id];
            c = [a[0].progress() > 0.0001, a[1].progress() > 0.0001];
            if (c[0] || c[1]) {
              d = b;
              b = new TimelineLite({
                paused: true,
                ease: Power3.easeInOut
              });
              if (c[0]) {
                b.add(a[0].reverse().timeScale(2, 0));
              }
              if (c[1]) {
                b.add(a[1].reverse().timeScale(2, 0));
              }
              b.add(d.play(0));
            }
            b.add(P.refresh);
            return b.play();
          });
          switch (event.type) {
          case 'pointerover':
            event.stopPropagation();
            a = V.el.console.cfg.data.hover;
            b = event.conf.id === 'left' ? 0 : 1;
            a[b].play();
            break;
          case 'pointerout':
            event.stopPropagation();
            a = V.el.console.cfg.data.hover;
            b = event.conf.id === 'left' ? 0 : 1;
            a[b].reverse();
            break;
          case 'click':
            event.stopPropagation();
            a = event.conf.id === 'left' ? 0 : 1;
            return dat.change(a);
          case 'keydown':
            a = event.conf.keys.indexOf(event.key);
            if (a < 0) {
              break;
            }
            event.preventDefault();
            event.stopImmediatePropagation();
            if (a < 2) {
              return dat.change(a);
            }
            for (i$ = 0, len$ = (ref$ = cfg.context.cfg.data.btn).length; i$ < len$; ++i$) {
              a = ref$[i$];
              if (a['class'].has('active')) {
                break;
              }
            }
            a = a.dataset.id;
            M[cfg.level] = a;
            P.update();
          }
        }
      }
      return false;
    }
  }
});