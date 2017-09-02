// Generated by LiveScript 1.5.0
'use strict';
$('document').ready(function(){
  var M, V, P;
  if (!w3ui) {
    return;
  }
  M = {
    nav: w3ui.PROXY({
      arch: [],
      data: [
        {
          id: ''
        }, {
          id: ''
        }, {
          id: ''
        }, {
          id: ''
        }
      ],
      restore: true,
      keys: function(){
        var this$ = this;
        return this.data.map(function(it){
          return it.id;
        });
      }
    }, {
      init: function(){
        var i$, to$, a;
        for (i$ = 0, to$ = this.data.length - 1; i$ <= to$; ++i$) {
          a = i$;
          this.arch[a] = {
            '': w3ui.CLONE(this.data.slice(a + 1))
          };
        }
        return true;
      },
      set: function(obj, p, v, prx){
        var n, w, a;
        if (typeof p !== 'string' || isNaN(parseInt(p))) {
          obj[p] = v;
          return true;
        }
        p = +p;
        n = obj.data.length;
        if (p < 0 || p >= n) {
          return true;
        }
        w = obj.data[p].id;
        if (w === v && v === '') {
          return true;
        }
        if (v === w) {
          v = '';
        }
        if (w) {
          obj.arch[p][w] = obj.data.slice(p + 1, n);
        }
        a = obj.arch[p][v] && obj.restore ? v : '';
        obj.data.splice(p + 1, n);
        obj.data = obj.data.concat(w3ui.CLONE(obj.arch[p][a]));
        obj.data[p].id = v;
        return true;
      },
      get: function(obj, p, prx){
        if (typeof p !== 'string' || isNaN(parseInt(p))) {
          return obj[p];
        }
        p = +p;
        if (p < 0 || p >= obj.data.length) {
          return null;
        }
        return obj.data[p];
      }
    }),
    authorized: true,
    mode: 0,
    init: function(){
      return true;
    }
  };
  V = {
    color: w3ui.PROXY({
      source: null,
      Hue: '',
      Saturation: '',
      colors: null,
      gradient: {},
      init: function(){
        var a, i$, b, c;
        a = this.source
          ? this.source
          : $("html");
        if (!a || a.length === 0) {
          return false;
        }
        this.source = a;
        a = window.getComputedStyle(a[0]);
        this.Hue = a.getPropertyValue('--col-h').trim();
        this.Saturation = a.getPropertyValue('--col-s').trim();
        this.colors = {};
        for (i$ = 0; i$ <= 99; ++i$) {
          b = i$;
          c = '--col' + b;
          if (a.getPropertyValue(c)) {
            this.colors[c] = b;
          }
          c = c + 'a';
          if (a.getPropertyValue(c)) {
            this.colors[c] = -b;
          }
        }
        for (i$ = 0; i$ <= 99; ++i$) {
          b = i$;
          if (!(c = a.getPropertyValue('--gr' + b))) {
            break;
          }
          this.gradient['gr' + b] = c.trim();
        }
        return this.select(this.Hue);
      },
      select: function(Hue, Saturation){
        var a, b, ref$, c, d, e;
        Saturation == null && (Saturation = this.Saturation);
        if (!Hue || !Saturation || !this.source) {
          return false;
        }
        this.Hue = Hue;
        this.Saturation = Saturation;
        a = window.getComputedStyle(this.source[0]);
        for (b in ref$ = this.colors) {
          c = ref$[b];
          if (d = a.getPropertyValue(b)) {
            if (c >= 0) {
              e = 'hsla(' + Hue + ', ' + Saturation + '%, ' + c + '%, 1)';
              if (e !== d.trim()) {
                this.source[0].style.setProperty(b, e);
              }
            } else {
              c = -c;
              e = 'hsla(' + Hue + ', ' + Saturation + '%, ' + c + '%, 0)';
              if (e !== d.trim()) {
                this.source[0].style.setProperty(b, e);
              }
            }
          }
        }
        for (b in this.gradient) {
          this.source[0].style.setProperty('--' + b, this[b]);
        }
        return true;
      }
    }, {
      get: function(obj, p, prx){
        var a;
        if (typeof p !== 'string') {
          a = null;
        } else if (obj[p]) {
          a = obj[p];
        } else if (parseInt(p)) {
          a = 'hsla(' + obj.Hue + ',' + obj.Saturation + '%,' + p + '%,1)';
        } else if ('a' === p.charAt(0)) {
          p = p.slice(1);
          a = 'hsla(' + obj.Hue + ',' + obj.Saturation + '%,' + p + '%,0)';
        } else if (obj.gradient[p]) {
          a = obj.gradient[p];
          a = a.replace(/(--col(\d{2})([a]?))/g, function(all, p1, p2, p3, pos, str){
            var a;
            a = p3 ? p3 + p2 : p2;
            if (!(a = prx[a])) {
              a = 'transparent';
            }
            return a;
          });
        } else {
          a = '';
        }
        return a;
      }
    }),
    svg: w3ui.PROXY({
      data: null,
      init: function(){
        var a, i$, to$, b;
        this.data = {};
        if (!(a = $('#t-svg')) || a.length === 0) {
          return false;
        }
        a = $(a[0].content).find('div');
        for (i$ = 0, to$ = a.length - 1; i$ <= to$; ++i$) {
          b = i$;
          this.data[a[b].id] = a[b].innerHTML;
        }
        return true;
      }
    }, {
      get: function(obj, p, prx){
        if (typeof p === 'string') {
          if (obj[p]) {
            return obj[p];
          }
          if (obj.data[p]) {
            return obj.data[p];
          }
        }
        return '';
      }
    }),
    skel: w3ui.PROXY({
      cfg: {
        id: 'wa',
        node: null,
        parent: null,
        level: 0,
        nav: null,
        init: function(){
          return true;
        },
        refresh: function(){
          var node, i$, a;
          node = this.cfg.node;
          for (i$ = M.nav.data.length; i$ >= 1; --i$) {
            a = i$;
            node.toggleClass('n' + a, !!M.nav[a - 1].id);
          }
          node.toggleClass('auth', !M.authorized);
          node.toggleClass('m0', M.mode === 0);
          node.toggleClass('m1', M.mode === 1);
          node.toggleClass('m2', M.mode === 2);
          if (0 + node[0].style.opacity < 0.99) {
            TweenMax.to(node, 2, {
              opacity: 1,
              ease: Power1.easeOut
            });
          }
          return true;
        }
      },
      modebar: {
        cfg: {
          mode: {
            node: null,
            icon: '',
            enabled: false,
            size: null,
            index: -1
          },
          title: {
            node: null,
            size: null,
            index: 0
          },
          conf: {
            node: null,
            icon: '',
            enabled: false,
            size: null,
            index: -1
          },
          init: function(){
            this.cfg.mode.node = w3ui('#' + this.cfg.id + ' .m1');
            this.cfg.title.node = w3ui('#' + this.cfg.id + ' .box2');
            this.cfg.conf.node = w3ui('#' + this.cfg.id + ' .m2');
            this.cfg.conf.icon = V.svg.modebarConfig;
            return true;
          },
          refresh: function(){
            var a;
            ['mode', 'conf'].forEach(function(name){
              var a, b;
              a = this[name];
              b = this.cfg[name];
              b.node.prop('disabled', !b.enabled);
              if (!b.enabled) {
                b.node.html('');
                return;
              }
              a = b.index >= 0 && a[b.index]
                ? a[b.index]
                : b.icon;
              b.node.html(a);
            }, this);
            a = this.cfg.title;
            a.node.html(this.title[a.index]);
            return true;
          },
          resize: function(){
            var i$, ref$, len$, a, b, c;
            for (i$ = 0, len$ = (ref$ = Object.keys(this)).length; i$ < len$; ++i$) {
              a = ref$[i$];
              if (a !== 'cfg') {
                b = this.cfg[a];
                a = this[a];
                c = [parseInt(b.node.style.fontSizeMin), parseInt(b.node.style.fontSizeMax)];
                if (isNaN(c[0])) {
                  c[0] = 0;
                }
                if (isNaN(c[1])) {
                  c[1] = 64;
                }
                if (!a) {
                  continue;
                }
                b.size = a.map(fn$);
              }
            }
            ['mode', 'conf'].forEach(function(name){
              var a, b, c;
              a = this.cfg[name];
              b = this[name];
              if (!b) {
                a.index = -1;
                return;
              }
              c = Math.max.apply(null, a.size);
              a.index = a.size.findIndex(function(val){
                return val - c < 0.0001;
              });
              b = a.size[a.index];
              a.node.style.fontSize = b + 'px';
            }, this);
            a = this.cfg.title;
            b = a.size[a.index];
            a.node.style.fontSize = b + 'px';
            this.cfg.root.style.f1SizeMax = a.size[0];
            return true;
            function fn$(text){
              var a;
              if (!text) {
                return 0;
              }
              a = b.node.textMeasureFont(text);
              if (a < c[0]) {
                a = c[0];
              }
              if (a > c[1]) {
                a = c[1];
              }
              return a;
            }
          }
        },
        mode: null,
        conf: ['Настройки', 'Настр', ''],
        title: ['Главное меню', '', 'Конфигурация']
      },
      view: {
        cfg: {
          init: function(){
            var a;
            switch (M.mode) {
            case 0:
              a = 'menu';
              break;
            case 1:
              return true;
            case 2:
              return true;
            default:
              return false;
            }
            this.cfg.render(a);
            return true;
          },
          refresh: function(){
            return true;
          },
          resize: function(){
            return true;
          }
        },
        menu: {
          cfg: {
            resize: function(){
              return true;
            }
          },
          list: [
            {
              id: 'card',
              name: 'Картотека'
            }, {
              id: 'm2',
              name: '2'
            }, {
              id: 'm3',
              name: '3'
            }, {
              id: 'm4',
              name: '4'
            }, {
              id: 'm5',
              name: '5'
            }, {
              id: 'm6',
              name: '6'
            }
          ],
          card: ['Картотека', 'Карта', '']
        }
      },
      console: {
        cfg: {
          empty: true
        },
        log: {
          error: ['Ошибка', 'в доступе отказано'],
          warning: 'Предупреждение',
          info: ['Статус', 'активирован тестовый режим', 'подключение к серверу установлено', 'подключение к серверу не установлено', 'загрузка ключевого контейнера', 'аутентификация', 'авторизация', 'доступ разрешен', 'авторизация завершена']
        }
      }
    }, {
      get: function(obj, id, prx){
        var a, b, k, v, own$ = {}.hasOwnProperty;
        if (!id || id === 'wa') {
          return obj;
        }
        if (obj[id]) {
          return obj[id];
        }
        if (!obj.cfg) {
          return null;
        }
        a = [obj];
        while (a.length) {
          b = a.pop();
          for (k in b) if (own$.call(b, k)) {
            v = b[k];
            if (k !== 'cfg' && v && v.cfg) {
              if (v[id]) {
                return v[id];
              }
              a.push(v);
            }
          }
        }
        return null;
      }
    }),
    go: function(nodeName, direction, args, method){
      var commonMethod, methodName, node, a;
      commonMethod = typeof method === 'string';
      methodName = commonMethod
        ? method
        : method.name;
      if (!(node = this.skel[nodeName]) || !node.cfg) {
        return true;
      }
      if (commonMethod) {
        a = node.cfg[method] && node.cfg.node ? node.cfg[method].apply(node, args) : true;
      } else {
        a = method.apply(node, args);
      }
      if (!a) {
        console.log('method [' + methodName + '] failed on element [' + nodeName + ']');
        return false;
      }
      if (direction) {
        for (a in node) {
          if (a !== 'cfg') {
            if (!this.go(a, direction, args, method)) {
              return false;
            }
          }
        }
      } else {
        if (a = node.cfg.parent) {
          if (!this.go(a, direction, args, method)) {
            return false;
          }
        }
      }
      return true;
    },
    init: function(){
      var root, f;
      if (!this.color.init()) {
        console.log('color.init failed');
        return false;
      }
      if (!this.svg.init()) {
        console.log('svg.init failed');
        return false;
      }
      root = w3ui('html');
      f = function(id, parent, level){
        var a, b, c;
        id == null && (id = 'wa');
        parent == null && (parent = null);
        level == null && (level = 0);
        if (!(a = this.skel[id])) {
          console.log('getting element [' + id + '] failed');
          return false;
        }
        a.cfg.id = id;
        a.cfg.node = w3ui('#' + id);
        a.cfg.parent = parent;
        a.cfg.root = root;
        a.cfg.level = level;
        a.cfg.nav = M.nav[level];
        a.cfg.render = function(id){
          var b;
          if (!(b = $('#t-' + a.cfg.id)) || b.length === 0) {
            return true;
          }
          if (id) {
            b = $(b[0].content).find('#' + id);
            b = b[0].innerHTML;
            b = Mustache.render(b, a[id]);
          } else {
            b = b[0].content;
          }
          a.cfg.node.html(b);
          return true;
        };
        for (b in a) {
          c = a[b];
          if (b !== 'cfg' && c && c.cfg) {
            if (!f.apply(this, [b, c, level + 1])) {
              return false;
            }
          }
        }
        return true;
      };
      return f.apply(this) && this.go('wa', true, [], 'init');
    },
    refresh: function(){
      return this.go('wa', true, [], 'refresh');
    },
    resize: function(){
      this.go('wa', true, [], 'resize');
    },
    GSAP: {
      busy: 0,
      show: function(args, onComplete){
        var me, gs, op, a;
        args == null && (args = {});
        if (typeof args === 'function') {
          onComplete = args;
          args = {};
        }
        if (args.show === undefined) {
          args.show = true;
        }
        if (args.time === undefined) {
          args.time = args.show ? 0.8 : 0.4;
        }
        me = this;
        gs = V.GSAP;
        op = args.show ? 1 : 0;
        if (me.onComplete) {
          me.onComplete();
        }
        if (args.time > 0) {
          a = me[0].style.opacity;
          a = !a
            ? 0
            : +a;
          if (a === op) {
            return true;
          }
        } else {
          TweenMax.set(me, {
            opacity: op
          });
          return true;
        }
        gs.busy += 1;
        me.onComplete = function(){
          me.anim.kill();
          gs.busy -= 1;
          if (onComplete) {
            onComplete();
          }
          delete me.anim;
        };
        me.anim = new TimelineLite({
          paused: true,
          onComplete: me.onComplete
        });
        if (args.show) {
          me.anim.to(me, args.time, {
            opacity: 1,
            ease: Power1.easeOut
          }, 0);
        } else {
          me.anim.to(me, args.time, {
            opacity: 0,
            ease: Power1.easeIn
          }, 0);
        }
        me.anim.play();
        return true;
      },
      color: function(Hue){
        V.color.set(Hue);
        return V.refresh();
      },
      setBackground: function(bg, onComplete){
        var me, gs, d, a, i$, len$, b, t0, t1, t2;
        me = this.setBackground;
        gs = this;
        d = V.view;
        if (!d || !bg && !me.bg) {
          return false;
        }
        if (!bg) {
          bg = me.bg;
          delete me.bg;
        } else {
          a = [];
          for (i$ = 0, len$ = bg.length; i$ < len$; ++i$) {
            b = bg[i$];
            if (b) {
              a.push(V.color[b]);
            }
          }
          bg = a.length > 0 ? a.join(' , ') : 'none';
        }
        if (me.bg && me.bg === bg) {
          if (onComplete) {
            onComplete();
          }
          return false;
        }
        if (me.state) {
          me.state.vars.onComplete.apply(me.state);
        }
        a = new TimelineLite({
          paused: true,
          onComplete: function(){
            this.kill();
            gs.busy -= 1;
            me.bg = bg;
            if (onComplete) {
              onComplete();
            }
            delete me.state;
          }
        });
        t0 = 0;
        t1 = 0.8;
        t2 = 0.4;
        if (d[0].style.opacity !== '0') {
          if (me.bg === 'none') {
            a.set(d, {
              opacity: 0
            }, t0);
          } else {
            a.to(d, t2, {
              opacity: 0,
              ease: Power1.easeIn
            }, t0);
            t0 += t2;
          }
        }
        if (bg === 'none') {
          a.set(d, {
            backgroundImage: 'none',
            opacity: 1
          }, t0);
        } else {
          a.set(d, {
            backgroundImage: bg
          }, t0);
          a.to(d, t1, {
            opacity: 1,
            ease: Power1.easeOut
          }, t0);
        }
        me.state = a;
        gs.busy += 1;
        a.play();
        return true;
      },
      setNote: function(num){
        var me, a;
        num == null && (num = 0);
        me = this.setNote;
        a = V.lang.note[num];
        if (me.num === num) {
          return false;
        }
        me.num = num;
        V.note.html(a);
        return false;
      },
      auth: function(){
        var me, gs, dt, render, anim, m_enter, m_leave, m_click;
        me = this.auth;
        gs = this;
        if (me.state) {
          return false;
        }
        dt = {
          anim: null,
          radius: 4,
          R: 0,
          timeout: 4,
          p_count: 0,
          p_size0: 0.5,
          p_size1: 2.0,
          p_speed: 5,
          p_acc: 0.00005,
          stars: []
        };
        render = function(){
          var a, cw, ch, cx, cy, i$, to$, r0, r1, r2, star, vx, vy;
          a = V.s.canvas[0];
          cw = a.width;
          ch = a.height;
          cx = cw / 2;
          cy = ch / 2;
          for (i$ = 1, to$ = dt.p_count; i$ <= to$; ++i$) {
            a = i$;
            r0 = Math.random();
            r1 = Math.random() + 0.2 * r0;
            r2 = 360 * Math.random();
            dt.stars.push({
              x: cx + dt.R * Math.cos(r2 * Math.PI / 180),
              y: cy + dt.R * Math.sin(r2 * Math.PI / 180),
              r: 1,
              size: dt.p_size0 + (dt.p_size1 - dt.p_size0) * r0,
              speed: 1,
              accel: 1 + (1 + dt.p_speed * r1) / 1000,
              angle: r2
            });
          }
          if (dt.p_count > 0) {
            dt.timeout = 0;
          }
          a = [];
          dt.ctx.clearRect(0, 0, cw, ch);
          while (dt.stars.length) {
            star = dt.stars.pop();
            vx = star.speed * Math.cos(star.angle * Math.PI / 180);
            vy = star.speed * Math.sin(star.angle * Math.PI / 180);
            dt.ctx.beginPath();
            dt.ctx.lineWidth = star.size;
            dt.ctx.moveTo(star.x, star.y);
            star.x = star.x + vx;
            star.y = star.y + vy;
            dt.ctx.lineTo(star.x, star.y);
            dt.ctx.stroke();
            star.speed = star.speed * star.accel;
            star.accel = star.accel + dt.p_acc;
            if (star.x < cw && star.x > 0 && star.y < ch && star.y > 0) {
              a.push(star);
            }
          }
          dt.stars = a;
          return true;
        };
        anim = function(){
          var node;
          node = $('#auth g.node *');
          TweenMax.set(V.s.auth_svg, {
            boxShadow: '0px 0px 40px 8px ' + V.color[80]
          });
          return {
            hover: function(){
              var a, e, f, b, d;
              TweenMax.to(node[2], 0, {
                transformOrigin: 'center',
                fill: V.color[70],
                scale: 0,
                force3D: true
              });
              a = new TimelineLite({
                paused: true,
                onStart: function(){
                  var a;
                  a = this.getTweensOf(node[2]);
                  a[0].updateTo({
                    ease: Power4.easeOut
                  });
                  dt.p_count = 5;
                  dt.p_speed = 25;
                  return true;
                },
                onComplete: function(){
                  var a;
                  this.pause();
                  a = this.getTweensOf(node[2]);
                  a[0].updateTo({
                    ease: Power4.easeIn
                  });
                  this.vars.tw = TweenMax.to(node[2], 0.5, {
                    scale: 0.77,
                    fill: V.color[80],
                    repeat: -1,
                    yoyo: true,
                    ease: Circ.easeIn
                  });
                  return true;
                },
                onReverse: function(){
                  return true;
                },
                onReverseComplete: function(){
                  this.pause();
                  return true;
                }
              });
              a.stopit = function(){
                dt.p_count = 1;
                dt.p_speed = 5;
                if (this.vars.tw) {
                  this.vars.tw.kill();
                  delete this.vars.tw;
                }
                return true;
              };
              a.vars.onReverse = a.stopit;
              e = 0;
              f = Power2.easeInOut;
              b = TweenMax.to(V.s.auth_svg, 0.4, {
                boxShadow: '0px 0px 60px 10px ' + V.color[80],
                ease: f
              });
              a.add(b, e + 0.1);
              d = 0.4;
              b = TweenMax.to(V.s.auth_svg, d, {
                scale: 0.97,
                ease: f
              });
              a.add(b, e);
              d = 0.8;
              a.to(node[0], d, {
                fillOpacity: 0
              }, e);
              a.to(node[1], d, {
                fillOpacity: 1
              }, e);
              b = TweenMax.to(node[2], d, {
                fill: V.color[90],
                scale: 1
              });
              a.add(b, e);
              return a;
            }(),
            click: function(){
              return TweenMax.to(node[2], 0.5, {
                paused: true,
                mSVG: {
                  shape: node[5]
                },
                scale: 1,
                fill: V.color[87],
                ease: Back.easeOut,
                onStart: function(){
                  V.pb.eq(0).progressbar({
                    value: 100
                  });
                  V.pb.eq(1).progressbar({
                    value: 100
                  });
                  return true;
                },
                onComplete: function(){
                  this.pause();
                  dt.p_count = 4;
                  dt.p_speed = 8;
                  gs.setTitle(3);
                  return true;
                },
                onReverseComplete: function(){
                  dt.p_count = 1;
                  dt.p_speed = 5;
                  V.pb.eq(0).progressbar({
                    value: 0
                  });
                  V.pb.eq(1).progressbar({
                    value: 0
                  });
                  gs.setTitle(1);
                  return true;
                }
              });
            }(),
            wait: function(){
              var a;
              a = TweenMax.to(node[2], 2, {
                rotation: -240,
                paused: true,
                repeat: -1,
                ease: Power3.easeInOut
              });
              a.stop = function(){
                this.pause();
                this.stop.ok = false;
                TweenMax.to(node[2], 1, {
                  rotation: 0,
                  ease: Power3.easeIn,
                  onComplete: function(){
                    a.stop.ok = true;
                  }
                });
              };
              return a;
            }(),
            splash: function(){
              var a, e, d, f;
              a = new TimelineLite({
                paused: true,
                onComplete: function(){
                  this.pause();
                },
                onReverseComplete: function(){
                  this.pause();
                }
              });
              e = 0;
              a.set(V.view, {
                backgroundColor: V.color[95]
              }, e);
              a.set(node[0], {
                fill: 'url(#gr4)',
                fillOpacity: 0
              }, e);
              a.set(node[1], {
                fillOpacity: 1
              }, e);
              a.set(node[3], {
                transformOrigin: 'center',
                fill: V.color[80],
                scale: 1.2
              }, e);
              d = 2;
              a.to(node[2], d, {
                rotation: 0,
                fill: V.color[85],
                ease: Power3.easeInOut
              }, e);
              a.to(V.view, d, {
                backgroundColor: V.color[90],
                ease: Power2.easeIn,
                onComplete: function(){
                  a.set(V.view, {
                    backgroundImage: 'none'
                  });
                  true;
                }
              }, e);
              a.to(node[0], d, {
                fillOpacity: 1,
                ease: Power2.easeIn
              }, e);
              a.to(node[1], d, {
                fillOpacity: 0,
                ease: Power2.easeIn
              }, e);
              a.to(V.s.auth_svg, d, {
                boxShadow: '0px 0px 6px 2px ' + V.color[80]
              }, e);
              e = e + d - 0.5;
              a.to(node[3], d, {
                fillOpacity: 1,
                scale: 1,
                ease: Power3.easeInOut,
                onStart: function(){
                  gs.setNote(9);
                  return true;
                }
              }, e);
              e = e + d;
              a.set(node[1], {
                fill: V.color[95]
              }, e);
              a.to(node[0], d, {
                fillOpacity: 0,
                ease: Power2.easeIn
              }, e);
              a.to(node[1], d, {
                fillOpacity: 1,
                ease: Power2.easeIn
              }, e);
              a.to(node[2], 0.8, {
                mSVG: {
                  shape: node[6],
                  shapeIndex: 2
                },
                fill: V.color[80],
                ease: Back.easeOut
              }, e - d);
              a.set(V.s.auth_svg, {
                clearProps: 'boxShadow',
                onComplete: function(){
                  V.s.auth_svg.css('box-shadow', 'none');
                  gs.setNote(11);
                }
              }, e);
              f = Back.easeOut;
              d = 1.0;
              a.to(V.view, d, {
                backgroundColor: V.color[90],
                ease: f
              }, e);
              a.set(V.view, {
                backgroundImage: 'none'
              }, e + d);
              a.set(node[0], {
                fill: V.color[90]
              }, e);
              a.to(node[0], d, {
                fillOpacity: 1,
                ease: f
              }, e);
              a.to(node[1], d, {
                fillOpacity: 0,
                ease: f
              }, e);
              e = e - 0.5;
              d = 1.0;
              a.to(V.s.auth_svg, d, {
                scale: 1.3,
                ease: f
              }, e);
              a.to(node[3], d, {
                mSVG: {
                  shape: node[10],
                  shapeIndex: 0
                },
                ease: f
              }, e);
              a.to(node[2], d, {
                fill: V.color[80],
                ease: f
              }, e);
              a.to(node[3], d, {
                fill: V.color[80],
                ease: f
              }, e);
              return a;
            }(),
            finish: function(){
              var a, e, d, f;
              a = new TimelineLite({
                paused: true,
                onComplete: function(){
                  this.pause();
                },
                onReverseComplete: function(){
                  this.pause();
                }
              });
              e = 0;
              d = 1;
              f = Back.easeIn;
              a.to(node[1], d, {
                fill: V.color[90],
                ease: f
              }, e);
              a.to(V.s.auth_svg, d, {
                scale: 0.9,
                ease: f
              }, e);
              a.to(node[3], d, {
                mSVG: {
                  shape: node[9],
                  shapeIndex: 0
                },
                ease: f
              }, e);
              a.to(node[2], d, {
                fill: V.color[90],
                ease: f
              }, e);
              e = e + d;
              d = 2;
              f = Power0.easeNone;
              a.set(node[2], {
                fillOpacity: 0,
                onComplete: function(){
                  gs.setNote(12);
                  return true;
                }
              }, e);
              a.to(V.s.auth_svg, d, {
                scale: 0,
                ease: f
              }, e);
              a.to(node[1], d, {
                fill: V.color[60],
                ease: f
              }, e);
              a.to(node[3], d, {
                fill: V.color[60],
                ease: f
              }, e);
              d = 2.5;
              e = e - 0.5;
              a.to(V.view, d, {
                opacity: 0,
                ease: f
              }, e);
              return a;
            }()
          };
        };
        m_enter = function(){
          var a;
          if (dt.clicked) {
            return true;
          }
          dt.moused = true;
          gs.setNote(1);
          a = dt.anim.hover;
          if (a.paused() || a.reversed()) {
            a.play();
          }
          return true;
        };
        m_leave = function(){
          var a;
          if (dt.clicked) {
            return true;
          }
          dt.moused = false;
          gs.setNote(0);
          a = dt.anim.hover;
          if (!a.reversed()) {
            a.reverse();
          }
          return true;
        };
        m_click = function(){
          if (dt.clicked === 1) {
            return true;
          }
          if (dt.clicked === 2) {
            dt.clicked = 0;
            return true;
          }
          if (dt.clicked) {
            return false;
          }
          if (!dt.moused) {
            m_enter();
          }
          dt.clicked = 1;
          w3ui.THREAD(this, [
            function(){
              return dt.anim.hover.paused();
            }, function(){
              dt.anim.hover.stopit();
              return true;
            }, function(){
              gs.setNote(5);
              dt.anim.click.play();
              return true;
            }, function(){
              return dt.anim.click.paused();
            }, function(){
              /* DEBUG */
              if (true) {
                BOUNCE(this, 5000, [], function(){
                  var a, b;
                  a = dt.anim.click;
                  b = a.vars.onReverseComplete;
                  a.vars.onReverseComplete = function(){
                    b();
                    dt.anim.hover.reverse();
                    dt.clicked = 0;
                    if (dt.moused) {
                      m_leave();
                    }
                    a.vars.onReverseComplete = b;
                  };
                  dt.anim.click.reverse();
                });
                return null;
              }
              /**/
              return true;
            }, function(){
              if (false) {
                gs.setNote(7);
                dt.anim.click.eventCallback('onReverseComplete', function(){
                  m_leave();
                });
                dt.anim.click.reverse();
                dt.clicked = 0;
                return null;
              }
              gs.setNote(8);
              dt.p_count = 0;
              dt.p_acc = dt.p_acc * 10;
              return true;
            }, function(){
              dt.anim.splash.play();
              return true;
            }, function(){
              return dt.anim.splash.paused();
            }, function(){
              return dt.clicked === 2;
            }, function(){
              dt.anim.finish.play();
              return true;
            }, function(){
              return dt.anim.finish.paused();
            }, function(){
              gs.setNote(0);
              me.state();
              P.init();
              return true;
            }
          ]);
          return true;
        };
        V.s.auth_btn.mouseenter(m_enter);
        V.s.auth_btn.mouseleave(m_leave);
        V.s.auth_btn.click(m_click);
        me.init = function(){
          var a;
          if (dt.animate) {
            dt.animate = false;
            BOUNCE(me, 50, [], me.init);
            return true;
          }
          dt.R = dt.radius + V.s.auth_svg.height() / 2;
          a = V.s.canvas[0];
          a.width = V.s.canvas.width();
          a.height = V.s.canvas.height();
          dt.ctx = a.getContext('2d');
          dt.ctx.strokeStyle = V.color[60];
          dt.anim = anim();
          dt.animate = true;
          me.animate();
          return true;
        };
        me.animate = function(){
          if (dt.animate) {
            if (me.state) {
              dt.id = window.requestAnimationFrame(me.animate);
            }
            render();
          }
        };
        me.state = function(){
          if (dt.animate) {
            dt.animate = false;
            if (dt.id) {
              window.cancelAnimationFrame(dt.id);
            }
          }
          delete me.state;
          delete me.dt;
        };
        me.dt = dt;
        if (dt.timeout) {
          BOUNCE(me, 1000 * dt.timeout, [], function(){
            if (dt.timeout !== 0) {
              dt.p_count = 1;
            }
          });
        }
        return me.init();
      }
    }
  };
  P = {
    init: function(){
      if (!M.init() || !V.init()) {
        return false;
      }
      P.updateView();
      $(window).on('resize', function(){
        P.windowResize();
      });
      /***
      # synchronize navigation {{{
      if M.authorized
          # determine changes
          m = M.nav.keys!
          v = V.nav.keys!
          x = [false] * m.length
          for a,b in m
              # compare main factor (id)
              # store result of comparison
              if a != v[b]
                  # change detected
                  x[b] = true
                  # propagate it to upper levels
                  for c from b + 1 to m.length - 1
                      x[c] = true
                  # finish
                  break
              # compare additional factors
              for own a,c of M.nav.data[b] when c != V.nav.data[b][a]
                  # change detected
                  # do not propagate it
                  x[b] = true
                  break
          # synchronize
          for a,b in M.nav.data
              V.nav.data[b] = w3ui.CLONE a
      else
          # no navigation
          m = [''] * a
          x = [true] * m.length
          V.nav.data.forEach (a) -> a.id = ''
      # }}}
      /***/
      return true;
    },
    updateView: function(){
      V.resize();
      V.refresh();
    },
    windowResize: function(){
      var me, f;
      me = this.windowResize;
      if (me.timer) {
        window.clearTimeout(me.timer);
        f = w3ui.PARTIAL(this, me);
        me.timer = window.setTimeout(f, 250);
      } else {
        this.updateView();
      }
    },
    navigate: function(nav, onComplete){
      var i$, len$, b, a;
      if (!this.sync) {
        return false;
      }
      if (nav && M.authorized) {
        M.nav.restore = false;
        for (i$ = 0, len$ = nav.length; i$ < len$; ++i$) {
          b = i$;
          a = nav[i$];
          M.nav.data[b].id = a;
          V.nav.data[b].id = '';
        }
        M.nav.restore = true;
      }
      this.sync(function(){
        V.resize(0, function(){
          V.refresh();
          if (onComplete) {
            onComplete();
          }
        });
      });
      return true;
    },
    nav: function(level, key, value, onComplete){
      if (V.state !== 0) {
        return false;
      }
      if (key === 'id') {
        M.nav[level] = value;
        this.navigate(false, onComplete);
      } else {
        M.nav[level][key] = value;
        V.nav[level][key] = value;
        V.resize(0, function(){
          V.refresh(onComplete);
        });
      }
      return true;
    },
    switchNavOpt: function(level, opt){
      var a;
      if (P.sync.state || !M.authorized) {
        return false;
      }
      a = !M.nav[level][opt];
      M.nav[level][opt] = a;
      V.nav[level][opt] = a;
      V.resize(false);
      V.refresh();
      return true;
    }
  };
  if (M && V && P) {
    return P.init();
  }
});