(function() {
  var AnimatedText, AnimatedTextFactory, Bar, Donut, Gauge, GaugePointer, ValueUpdater, addCommas, formatNumber, secondsToString, updateObjectValues;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  (function() {
    var browserRequestAnimationFrame, isCancelled, lastId, vendor, vendors, _i, _len;
    vendors = ['ms', 'moz', 'webkit', 'o'];
    for (_i = 0, _len = vendors.length; _i < _len; _i++) {
      vendor = vendors[_i];
      if (window.requestAnimationFrame) {
        break;
      }
      window.requestAnimationFrame = window[vendor + 'RequestAnimationFrame'];
      window.cancelAnimationFrame = window[vendor + 'CancelAnimationFrame'] || window[vendor + 'CancelRequestAnimationFrame'];
    }
    browserRequestAnimationFrame = null;
    lastId = 0;
    isCancelled = {};
    if (!requestAnimationFrame) {
      window.requestAnimationFrame = function(callback, element) {
        var currTime, id, lastTime, timeToCall;
        currTime = new Date().getTime();
        timeToCall = Math.max(0, 16 - (currTime - lastTime));
        id = window.setTimeout(function() {
          return callback(currTime + timeToCall);
        }, timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };
      return window.cancelAnimationFrame = function(id) {
        return clearTimeout(id);
      };
    } else if (!window.cancelAnimationFrame) {
      browserRequestAnimationFrame = window.requestAnimationFrame;
      window.requestAnimationFrame = function(callback, element) {
        var myId;
        myId = ++lastId;
        browserRequestAnimationFrame(function() {
          if (!isCancelled[myId]) {
            return callback();
          }
        }, element);
        return myId;
      };
      return window.cancelAnimationFrame = function(id) {
        return isCancelled[id] = true;
      };
    }
  })();
  String.prototype.hashCode = function() {
    var char, hash, i, _ref;
    hash = 0;
    if (this.length === 0) {
      return hash;
    }
    for (i = 0, _ref = this.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      char = this.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return hash;
  };
  secondsToString = function(sec) {
    var hr, min;
    hr = Math.floor(sec / 3600);
    min = Math.floor((sec - (hr * 3600)) / 60);
    sec -= (hr * 3600) + (min * 60);
    sec += '';
    min += '';
    while (min.length < 2) {
      min = '0' + min;
    }
    while (sec.length < 2) {
      sec = '0' + sec;
    }
    hr = hr ? hr + ':' : '';
    return hr + min + ':' + sec;
  };
  formatNumber = function(num) {
    return addCommas(num.toFixed(0));
  };
  updateObjectValues = function(obj1, obj2) {
    var key, val, _results;
    _results = [];
    for (key in obj2) {
      if (!__hasProp.call(obj2, key)) continue;
      val = obj2[key];
      _results.push(obj1[key] = val);
    }
    return _results;
  };
  addCommas = function(nStr) {
    var rgx, x, x1, x2;
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = '';
    if (x.length > 1) {
      x2 = '.' + x[1];
    }
    rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
  };
  ValueUpdater = (function() {
    ValueUpdater.prototype.animationSpeed = 32;
    function ValueUpdater() {
      AnimationUpdater.add(this);
    }
    ValueUpdater.prototype.update = function() {
      var diff;
      if (this.displayedValue !== this.value) {
        if (this.ctx) {
          this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        }
        diff = this.value - this.displayedValue;
        if (Math.abs(diff / this.animationSpeed) <= 0.001) {
          this.displayedValue = this.value;
        } else {
          this.displayedValue = this.displayedValue + diff / this.animationSpeed;
        }
        this.render();
        return true;
      }
      return false;
    };
    return ValueUpdater;
  })();
  AnimatedText = (function() {
    __extends(AnimatedText, ValueUpdater);
    AnimatedText.prototype.displayedValue = 0;
    AnimatedText.prototype.value = 0;
    AnimatedText.prototype.setVal = function(value) {
      return this.value = 1 * value;
    };
    function AnimatedText(elem, text) {
      this.elem = elem;
      this.text = text != null ? text : false;
      this.value = 1 * this.elem.innerHTML;
      if (this.text) {
        this.value = 0;
      }
    }
    AnimatedText.prototype.render = function() {
      var textVal;
      if (this.text) {
        textVal = secondsToString(this.displayedValue.toFixed(0));
      } else {
        textVal = addCommas(formatNumber(this.displayedValue));
      }
      return this.elem.innerHTML = textVal;
    };
    return AnimatedText;
  })();
  AnimatedTextFactory = {
    create: function(objList) {
      var elem, out, _i, _len;
      out = [];
      for (_i = 0, _len = objList.length; _i < _len; _i++) {
        elem = objList[_i];
        out.push(new AnimatedText(elem));
      }
      return out;
    }
  };
  GaugePointer = (function() {
    GaugePointer.prototype.strokeWidth = 3;
    GaugePointer.prototype.length = 76;
    GaugePointer.prototype.options = {
      strokeWidth: 0.035,
      length: 0.1
    };
    function GaugePointer(ctx, canvas) {
      this.ctx = ctx;
      this.canvas = canvas;
      this.setOptions();
    }
    GaugePointer.prototype.setOptions = function(options) {
      if (options == null) {
        options = null;
      }
      updateObjectValues(this.options, options);
      this.length = this.canvas.height * this.options.length;
      return this.strokeWidth = this.canvas.height * this.options.strokeWidth;
    };
    GaugePointer.prototype.render = function(angle) {
      var centerX, centerY, endX, endY, startX, startY, x, y;
      centerX = this.canvas.width / 2;
      centerY = this.canvas.height * 0.9;
      x = Math.round(centerX + this.length * Math.cos(angle));
      y = Math.round(centerY + this.length * Math.sin(angle));
      startX = Math.round(centerX + this.strokeWidth * Math.cos(angle - Math.PI / 2));
      startY = Math.round(centerY + this.strokeWidth * Math.sin(angle - Math.PI / 2));
      endX = Math.round(centerX + this.strokeWidth * Math.cos(angle + Math.PI / 2));
      endY = Math.round(centerY + this.strokeWidth * Math.sin(angle + Math.PI / 2));
      this.ctx.fillStyle = "black";
      this.ctx.beginPath();
      this.ctx.arc(centerX, centerY, this.strokeWidth, 0, Math.PI * 2, true);
      this.ctx.fill();
      this.ctx.beginPath();
      this.ctx.moveTo(startX, startY);
      this.ctx.lineTo(x, y);
      this.ctx.lineTo(endX, endY);
      return this.ctx.fill();
    };
    return GaugePointer;
  })();
  Bar = (function() {
    function Bar(elem) {
      this.elem = elem;
    }
    Bar.prototype.updateValues = function(arrValues) {
      this.value = arrValues[0];
      this.maxValue = arrValues[1];
      this.avgValue = arrValues[2];
      return this.render();
    };
    Bar.prototype.render = function() {
      var avgPercent, valPercent;
      if (this.textField) {
        this.textField.text(formatNumber(this.value));
      }
      if (this.maxValue === 0) {
        this.maxValue = this.avgValue * 2;
      }
      valPercent = (this.value / this.maxValue) * 100;
      avgPercent = (this.avgValue / this.maxValue) * 100;
      $(".bar-value", this.elem).css({
        "width": valPercent + "%"
      });
      return $(".typical-value", this.elem).css({
        "width": avgPercent + "%"
      });
    };
    return Bar;
  })();
  Gauge = (function() {
    __extends(Gauge, ValueUpdater);
    Gauge.prototype.elem = null;
    Gauge.prototype.value = 20;
    Gauge.prototype.maxValue = 80;
    Gauge.prototype.displayedAngle = 0;
    Gauge.prototype.displayedValue = 0;
    Gauge.prototype.lineWidth = 40;
    Gauge.prototype.paddingBottom = 0.1;
    Gauge.prototype.options = {
      colorStart: "#6fadcf",
      colorStop: "#8fc0da",
      strokeColor: "#e0e0e0",
      pointer: {
        length: 0.8,
        strokeWidth: 0.035
      },
      angle: 0.15,
      lineWidth: 0.44,
      fontSize: 40
    };
    function Gauge(canvas) {
      this.canvas = canvas;
      Gauge.__super__.constructor.call(this);
      this.ctx = this.canvas.getContext('2d');
      this.gp = new GaugePointer(this.ctx, this.canvas);
      this.setOptions();
      this.render();
    }
    Gauge.prototype.setOptions = function(options) {
      if (options == null) {
        options = null;
      }
      updateObjectValues(this.options, options);
      this.lineWidth = this.canvas.height * (1 - this.paddingBottom) * this.options.lineWidth;
      this.radius = this.canvas.height * (1 - this.paddingBottom) - this.lineWidth;
      this.gp.setOptions(this.options.pointer);
      if (this.textField) {
        this.textField.style.fontSize = options.fontSize + 'px';
      }
      return this;
    };
    Gauge.prototype.set = function(value) {
      this.value = value;
      if (this.value > this.maxValue) {
        this.maxValue = this.value * 1.1;
      }
      return AnimationUpdater.run();
    };
    Gauge.prototype.getAngle = function(value) {
      return (1 + this.options.angle) * Math.PI + (value / this.maxValue) * (1 - this.options.angle * 2) * Math.PI;
    };
    Gauge.prototype.setTextField = function(textField) {
      this.textField = textField;
    };
    Gauge.prototype.render = function() {
      var displayedAngle, grd, h, w;
      w = this.canvas.width / 2;
      h = this.canvas.height * (1 - this.paddingBottom);
      displayedAngle = this.getAngle(this.displayedValue);
      if (this.textField) {
        this.textField.innerHTML = formatNumber(this.displayedValue);
      }
      grd = this.ctx.createRadialGradient(w, h, 9, w, h, 70);
      this.ctx.lineCap = "butt";
      grd.addColorStop(0, this.options.colorStart);
      grd.addColorStop(1, this.options.colorStop);
      this.ctx.strokeStyle = grd;
      this.ctx.beginPath();
      this.ctx.arc(w, h, this.radius, (1 + this.options.angle) * Math.PI, displayedAngle, false);
      this.ctx.lineWidth = this.lineWidth;
      this.ctx.stroke();
      this.ctx.strokeStyle = this.options.strokeColor;
      this.ctx.beginPath();
      this.ctx.arc(w, h, this.radius, displayedAngle, (2 - this.options.angle) * Math.PI, false);
      this.ctx.stroke();
      return this.gp.render(displayedAngle);
    };
    return Gauge;
  })();
  Donut = (function() {
    __extends(Donut, ValueUpdater);
    Donut.prototype.lineWidth = 15;
    Donut.prototype.displayedValue = 0;
    Donut.prototype.value = 33;
    Donut.prototype.maxValue = 80;
    Donut.prototype.options = {
      lineWidth: 0.10,
      colorStart: "#6f6ea0",
      colorStop: "#c0c0db",
      strokeColor: "#eeeeee",
      angle: 0.35
    };
    function Donut(canvas) {
      this.canvas = canvas;
      Donut.__super__.constructor.call(this);
      this.ctx = this.canvas.getContext('2d');
      this.setOptions();
      this.render();
    }
    Donut.prototype.getAngle = function(value) {
      return (1 - this.options.angle) * Math.PI + (value / this.maxValue) * ((2 + this.options.angle) - (1 - this.options.angle)) * Math.PI;
    };
    Donut.prototype.setOptions = function(options) {
      if (options == null) {
        options = null;
      }
      updateObjectValues(this.options, options);
      this.lineWidth = this.canvas.height * this.options.lineWidth;
      this.radius = this.canvas.height / 2 - this.lineWidth / 2;
      if (this.textField) {
        this.textField.style.fontSize = options.fontSize + 'px';
      }
      return this;
    };
    Donut.prototype.setTextField = function(textField) {
      this.textField = textField;
    };
    Donut.prototype.set = function(value) {
      this.value = value;
      if (this.value > this.maxValue) {
        this.maxValue = this.value * 1.1;
      }
      return AnimationUpdater.run();
    };
    Donut.prototype.render = function() {
      var displayedAngle, grd, grdFill, h, start, stop, w;
      displayedAngle = this.getAngle(this.displayedValue);
      w = this.canvas.width / 2;
      h = this.canvas.height / 2;
      if (this.textField) {
        this.textField.innerHTML = formatNumber(this.displayedValue);
      }
      grdFill = this.ctx.createRadialGradient(w, h, 39, w, h, 70);
      grdFill.addColorStop(0, this.options.colorStart);
      grdFill.addColorStop(1, this.options.colorStop);
      start = this.radius - this.lineWidth / 2;
      stop = this.radius + this.lineWidth / 2;
      grd = this.ctx.createRadialGradient(w, h, start, w, h, stop);
      grd.addColorStop(0, "#d5d5d5");
      grd.addColorStop(0.12, this.options.strokeColor);
      grd.addColorStop(0.88, this.options.strokeColor);
      grd.addColorStop(1, "#d5d5d5");
      this.ctx.strokeStyle = grd;
      this.ctx.beginPath();
      this.ctx.arc(w, h, this.radius, (1 - this.options.angle) * Math.PI, (2 + this.options.angle) * Math.PI, false);
      this.ctx.lineWidth = this.lineWidth;
      this.ctx.lineCap = "round";
      this.ctx.stroke();
      this.ctx.strokeStyle = grdFill;
      this.ctx.beginPath();
      this.ctx.arc(w, h, this.radius, (1 - this.options.angle) * Math.PI, displayedAngle, false);
      return this.ctx.stroke();
    };
    return Donut;
  })();
  window.AnimationUpdater = {
    elements: [],
    animId: null,
    addAll: function(list) {
      var elem, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        elem = list[_i];
        _results.push(AnimationUpdater.elements.push(elem));
      }
      return _results;
    },
    add: function(object) {
      return AnimationUpdater.elements.push(object);
    },
    run: function() {
      var animationFinished, elem, _i, _len, _ref;
      animationFinished = true;
      _ref = AnimationUpdater.elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        elem = _ref[_i];
        if (elem.update()) {
          animationFinished = false;
        }
      }
      if (!animationFinished) {
        return AnimationUpdater.animId = requestAnimationFrame(AnimationUpdater.run);
      } else {
        return cancelAnimationFrame(AnimationUpdater.animId);
      }
    }
  };
  window.Gauge = Gauge;
  window.Donut = Donut;
}).call(this);