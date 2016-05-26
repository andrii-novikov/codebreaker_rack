App = {
    Game: {
        initialize: function () {
            $('input[name=guess]').select();
            $('[name=hint]').click(this.hint);
            $('[name=check]').click(this.checkGuess);
            $('[name=guess]').keydown(this.onGuessDown);
            $('[name=guess]').keyup(this.onGuessUp);
            $('.message').hide();
        },
        checkGuess: function () {
            var guess = $('input[name=guess]').val();
            if (App.Game.test(guess)) {
                $.ajax({
                    url: '/game/check',
                    method: 'POST',
                    data: {guess: guess}
                }).done(function (resp) {
                    $('.container.body').html(resp);
                    App.Game.initialize();
                    App.Over.initialize();
                });
            } else {
                App.Game.message('Guess must have 4 numbers from 1 to 6','warning')
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
                url: '/game/hint'
            }).done(function (resp) {
                App.Game.message(resp)
            });
        },
        message: function (message, type) {
            $('.message').hide();
            if (!$.isEmptyObject(message)) {
                var types = ['info', 'success', 'warning'];
                if (types.indexOf(type) < 0) {
                    type = 'info';
                }

                var container = $('.message.bg-'+type);
                container.html(message);
                container.slideDown();
            }
        }
    },
    Main: {
        initialize: function () {
            $('#play').click(this.play);
        },
        play: function (e) {
            e.preventDefault();

            if (this.form.name.value.trim().length > 1) {
                this.form.submit()
            } else {
                $('[name=hint]').text('Name must have 2 or more simbols');
                this.form.name.select()
            }
        }
    },
    Over: {
        initialize: function () {
            $('.question button').click(this.answer)
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

$(document).ready(function () {
    App.Game.initialize();
    App.Main.initialize();
    App.Over.initialize();
});