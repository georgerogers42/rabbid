require(["jquery", "underscore", "backbone"], function($, _, BackBone) {
	"use strict";
	var update = function(elt) {
		var i = $("<tr>");
		var n = $("<th>");
		var x = $("<td>");
		x.text(elt.text);
		n.text(elt.nick);
		i.append(n);
		i.append(x);
		i.show();
		$("#messages").append(i);
	};
	$(function() {
		(function() {
			var msgs = $("#messages");
			var req = $.ajax("/recv/all.json");
			req.done(function(data) {
				_.each(data, update);
			});
		}());
		var form = $("form#submit-message");
		form.on("submit", function(evt) {
			var self = this;
			var $self = $(self);
			evt.preventDefault();
			var req = $.ajax("/", {method: "post", data: {msg: $(self.msg).val(), nick: $(self.nick).val()}});
			return false;
		});
		(function loop() {
			var req = $.ajax("/recv.json", {method: "post"});
			req.done(function(data) {
				loop();
				_.each(data, update);
			});
		}());
	});
});
