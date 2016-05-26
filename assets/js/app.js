App = {
    initialize: function (e) {
        App.Game.initialize();
        App.Main.initialize();
        App.Over.initialize();
    },
    setElements: function () {
        $.each(this.elements, function (key, val) {
            this[key]=$(val);
        }.bind(this));
    },
    Game: {
        elements: {
            body: '.container.body',
            inptGuess: 'input[name=guess]',
            btnCheck: '[name=check]',
            btnHint: '[name=hint]'
        },
        initialize: function () {
            App.setElements.bind(this)();
            this.inptGuess.select().keydown(this.onGuessDown).keyup(this.onGuessUp);
            this.btnHint.click(this.hint.bind(this));
            this.btnCheck.click(this.checkGuess.bind(this));
        },

        checkGuess: function () {
            var guess = this.inptGuess.val();
            if (this.test(guess)) {
                $.ajax({
                    url: '/game/check',
                    method: 'POST',
                    data: {guess: guess},
                    context: this
                }).done(function (resp) {
                    this.body.html(resp);
                    App.initialize();
                });
            } else {
               alert('Guess must have 4 numbers from 1 to 6');
            }
        },
        onGuessDown: function (e) {
            $(this).attr('guess', $(this).val());
            if (e.key == 'Enter') {
                App.Game.checkGuess();
            }
        },
        onGuessUp: function (e) {
            if (!App.Game.test($(this).val())) {
                $(this).val($(this).attr('guess'));
            }
        },
        test: function (guess) {
            return null != guess.match(/^[1-6]{0,4}$/)
        },
        hint: function (e) {
            $.ajax({
                url: '/game/hint',
                method: 'POST',
                context:this
            }).done(this.onDone);
        },
        onDone: function (resp) {
            this.body.html(resp);
            App.initialize();
        }
    },
    Main: {
        elements: {
            btnPlay: '#play',
            name: '[name=name]',
            hint: ['name=hint']
        },
        initialize: function () {
            App.setElements.bind(this)();
            this.btnPlay.click(this.play);
            this.name.select();
        },
        play: function (e) {
            e.preventDefault();

            if (this.form.name.value.trim().length > 1) {
                this.form.submit()
            } else {
                this.hint.text('Name must have 2 or more simbols');
                this.form.name.select()
            }
        }
    },
    Over: {
        elements: {
            btnQuestion: '.question button'
        },
        initialize: function () {
            App.setElements.bind(this)();
            this.btnQuestion.click(this.answer)
        },
        answer: function (e) {
            var btn = $(this),
                question = btn.parents('.question'),
                questions = question.parents('.questions'),
                url = btn.attr('data-url'),
                action = btn.attr('data-action') || 'ajax';

            if (!$.isEmptyObject(url)) {

                if (action == 'location') {
                    document.location = url;
                }
                if (action == 'ajax') {
                    $.ajax({
                        url: url,
                        method: "POST"
                    })
                }
            }

            question.slideDown().remove();
            if (questions.children().length < 1) {
                questions.hide();
            }

        }
    }
};

$(document).ready(App.initialize);