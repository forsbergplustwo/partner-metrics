// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require chartkick
//= require bootstrap-select
//= require moment.min
//= require bootstrap-datepicker
//= require jquery-tablesorter
//
//= require_tree .

var setupAjax
setupAjax = function () {
  $(document).ajaxSend(function (e, xhr, options) {
    var token = $("meta[name='csrf-token']").attr('content')
    xhr.setRequestHeader('X-CSRF-Token', token)
  })
}

var pollImportStatus
pollImportStatus = function () {
  setInterval(function () {
    $.ajax({
      type: 'POST',
      url: '/import_status',
      timeout: 3000,
      success: function (data) {
        console.log(data)
        // if (data.label == "Failed") {
        //   $('#progress-bar').removeClass('progress-bar-info').addClass('progress-bar-danger');
        // }
        $('#progress-label').text(data.label + '...')
        $('#progress-bar')
          .css('width', data.amount_done + '%')
        if (data.reload == true) {
          window.location.replace(window.location)
        }
      },
      error: function (xhr) {
        if (xhr.status == 422) {
          window.location.replace(window.location)
        }
      }
    })
  }, 3000)
  return false
}

var setupUploads
setupUploads = function () {
  $(function () {
    if ($('#progress-bar').length == 0) {
      $('.directUpload').find('input:file').each(function (i, elem) {
        var fileInput = $(elem)
        var form = $(fileInput.parents('form:first'))
        var submitButton = form.find('input[type="submit"]')
        var progressBarLabel = $("<div id='progress-label'>&nbsp;</div>")
        var progressBar = $("<div id='progress-bar' class='progress-bar progress-bar-info progress-bar-striped active' role='progressbar' aria-valuenow='0' aria-valuemin='0' aria-valuemax='100' style='width:0%'>")
        var barContainer = $("<div class='progress'></div>").append(progressBar)
        var progressBarAfter = $('#progressPlaceholder')
        progressBarAfter.after(barContainer)
        progressBarAfter.after(progressBarLabel)
        fileInput.fileupload({
          fileInput: fileInput,
          url: form.data('url'),
          type: 'POST',
          autoUpload: true,
          formData: form.data('form-data'),
          paramName: 'file', // S3 does not like nested name fields i.e. name="user[avatar_url]"
          dataType: 'XML', // S3 returns XML if success_action_status is set to 201
          replaceFileInput: false,
          progressall: function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10)
            progressBar.css('width', progress + '%')
          },
          start: function (e) {
            $('#myModal').modal('show')
            submitButton.prop('disabled', true)
            progressBar
              .css('width', '0%')
              .text('')
            progressBarLabel.text('Uploading...')
          },
          done: function (e, data) {
            submitButton.prop('disabled', false)
            progressBar.text('')
            // extract key and generate URL from response
            var key = $(data.jqXHR.responseXML).find('Key').text()
            var encoded_key = encodeURIComponent(key)
            // var url   = '//' + form.data('host') + '/' + key;

            // create hidden field
            var input = $('<input />', { type: 'hidden', name: fileInput.attr('name'), value: key })
            form.append(input)
            $.ajax({
              type: 'POST',
              url: '/import',
              data: 'file=' + encodeURIComponent(key),
              success: function (data) {
                console.log('success!')
              }
            })
            pollImportStatus()
          },
          fail: function (e, data) {
            submitButton.prop('disabled', false)

            progressBar
              .css('background', 'red')
              .text('Failed')
          },
          add: function (e, data) {
            var uploadErrors = []
            // var acceptFileTypes = /(\.|\/)(zip|csv|rar|xlsx|xls|xlsm|ZIP|CSV|RAR|XLSX|XLS|XLSM)$/i;
            // if(data.files[0]['type'].length && !acceptFileTypes.test(data.files[0]['type'])) {
            //     uploadErrors.push('Not an accepted file type, must be zip or csv');
            // }
            if (data.files[0].size.length && data.files[0].size > 10000000) {
              uploadErrors.push('Filesize is too big, must be less than 10Mb')
            }
            if (uploadErrors.length > 0) {
              alert(uploadErrors.join('\n'))
            } else {
              data.submit()
            }
          }
        })
      })
    }
  })
}

var setupPartnerAPI
setupPartnerAPI = function () {
  $(function () {
    if ($('#progress-bar-partner-api').length == 0) {
      $('#partner_api_form').on('submit', function (e) {
        e.preventDefault();
        $.ajax({
          type: 'POST',
          url: e.target.action,
          data: $(this).serialize(),
          timeout: 3000,
          success: function (data) {
            console.log('success')
            pollImportStatus()
          },
          error: function (xhr) {
            console.log('error')
          }
        })
      })
    }
  })
}

var toggleLoading
toggleLoading = function () {
  $('#import_progress').show()
}
