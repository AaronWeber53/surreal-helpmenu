$(document).ready(function(){
  // LUA listener
  window.addEventListener('message', function( event ) {
    if (event.data.action == 'open') {
      if (event.data.open == true) {
        if (event.data.isAdmin) {
          $(".admin").show();        
        } else {
          $(".admin").hide();        
        }
        $("body").show();        
      } else {
        $("body").hide();
      }
    }
  });
  $(".main").load("pages/home.html" )

  $(".pageLink").on('click', function() {
    var pageName = $(this).data('page');
    $('.pageLink').removeClass('active')
    $(this).addClass('active')
    $('.lower').hide()
    $('#'+pageName).show()
    $(".main").load("pages/" + pageName + ".html" )
    if (pageName == "contact") {
      /* setTimeout(() => {
        showPlayerRequests([
          {
            response_value: 'InProgress',
            type: "F",
            discord: 'Amaterasu#0130',
            summary: 'Requesting new mission',
            created_date: new Date('7/8/2022'),
            last_updated: new Date('7/8/2022'),
            contact: 'Aaron',
            information: 'I want a new mission that allows players to attack the FIB building',
            
          },
          {
            response_value: 'Denied',
            type: "F",
            discord: 'Amaterasu#0130',
            summary: 'Requesting new mission',
            created_date: new Date('7/8/2022'),
            last_updated: new Date('7/8/2022'),
            contact: 'Aaron',
            information: 'I want a new mission that allows players to attack the FIB building',
            response_contact: "Amaterasu#0130",
            response_reason: "Already a feature"
          }
        ]);
      }, 250); */
      
      $.post(`https://${GetParentResourceName()}/playerRequests`,JSON.stringify({}),function(requestList){
        setTimeout(() => {
        showPlayerRequests(requestList); 
        }, 250)
      });
    } else if (pageName == "requests") {
      /* setTimeout(() => {
        showAdminRequests([
          {
            response_value: 'InProgress',
            type: "F",
            discord: 'Amaterasu#0130',
            summary: 'Requesting new mission',
            created_date: new Date('7/8/2022'),
            last_updated: new Date('7/8/2022'),
            contact: 'Aaron',
            information: 'I want a new mission that allows players to attack the FIB building',
            
          },
          {
            response_value: 'Denied',
            type: "F",
            discord: 'Amaterasu#0130',
            summary: 'Requesting new mission',
            created_date: new Date('7/8/2022'),
            last_updated: new Date('7/8/2022'),
            contact: 'Aaron',
            information: 'I want a new mission that allows players to attack the FIB building',
            response_contact: "Amaterasu#0130",
            response_reason: "Already a feature"
          }
        ]);
      }, 250); */
      $.post(`https://${GetParentResourceName()}/adminRequests`,JSON.stringify({}),function(requestList){
        setTimeout(() => {
          showAdminRequests(requestList); 
        }, 250)
      });
    }
  })
  $(".close").on('click', function() {
    close()
  })
  
  $(".lower a").on('click', function() {
    $('details').removeAttr('open')
    location.href = "#";
    var locationID = $(this).data('location')
    $('#'+locationID).parents('details').attr('open', '')
    location.href = "#" + locationID;
  })

  function formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [day, month, year].join('/');
}

  var showAdminRequests = function(list) {
    var activeRequestDiv = $('#activeRequest')
    var approvedRequestDiv = $('#approvedRequest')
    var deniedRequestDiv = $('#deniedRequest')
    
    var activeHTML = '';
    var approvedHTML = '';
    var deniedHTML = '';
    list.forEach(request => {
      var htmlRequest = `
        <details class="${request.response_value}">      
        <summary>(${request.type}) ${request.summary}</summary>
        <section>
          Requested (${formatDate(request.created_date)}) by ${request.contact}
          Discord Name: ${request.discord}
          
          ${request.information}
        </section>     
      `;

      if (request.response_value == 'InProgress') {
        htmlRequest += `
        <form>        
          <input type='hidden' id='id' name="id" value='${request.id}' />
            <label class="control-label " for="response_reason">
            Reason
            </label>
            <textarea class="form-control" maxlength='500' 
              cols="40" id="response_reason" name="response_reason" rows="10"></textarea>
             <button class="approve formSubmit" name="approve" type="submit">
              Approve
             </button>
             <button class="deny formSubmit" name="deny" type="submit">
              Deny
             </button>
        </form>
        `;
      } else if (request.response_contact) {
        htmlRequest += `
        <section class="${request.response_value}">
        <h4>Response - ${request.response_value}</h4>
        
        (${formatDate(request.last_updated)}) by ${request.response_contact}
        ${request.response_reason}
        </section>`;
      }
      htmlRequest += '</details>';
      switch (request.response_value) {
        case 'Approved':
          approvedHTML += htmlRequest          
          break;
        case 'Denied':
          deniedHTML += htmlRequest          
          break;      
        default:
          activeHTML += htmlRequest
          break;
      }
    });

    activeRequestDiv.html(activeHTML)  
    approvedRequestDiv.html(approvedHTML)  
    deniedRequestDiv.html(deniedHTML)  
  }

  var showPlayerRequests = function(list) {
    var playerRequests = $('#playerRequests')
    
    var htmlCombine = '';
    list.forEach(request => {
      var htmlRequest = `
        <details class="${request.response_value}">      
        <summary>(${request.type}) ${request.summary}</summary>
        <section>
          Requested (${formatDate(request.created_date)}) by ${request.contact}

          ${request.information}
        </section>     
      `;

      if (request.response_contact) {
        htmlRequest += `
        <section class="${request.response_value}">
        <h4>Response - ${request.response_value}</h4>
        
        (${formatDate(request.last_updated)}) by ${request.response_contact}
        ${request.response_reason}
        </section>`;
      }
      htmlRequest += '</details>';
      htmlCombine += htmlRequest
    });

    playerRequests.html(htmlCombine)
  }

  function convertFormToJSON(form) {
    return form
      .serializeArray()
      .reduce(function (json, { name, value }) {
        json[name] = value;
        return json;
      }, {});
  }

  $("body").on('click', '.formSubmit', function(evt) {
    evt.preventDefault();
    var eventValue = $(this).attr('name');
    var form = $(this).closest('form');
    if (form[0].checkValidity()) {
      var formData = convertFormToJSON(form)
      switch (eventValue) {
        case 'deny':
          $.post(`https://${GetParentResourceName()}/denyRequest`, JSON.stringify(formData));
          setTimeout(() => {
            $.post(`https://${GetParentResourceName()}/adminRequests`,JSON.stringify({}),function(requestList){
              showAdminRequests(requestList); 
            });    
          }, 500);        
          break;
        case 'approve':
          $.post(`https://${GetParentResourceName()}/approveRequest`, JSON.stringify(formData)); 
          setTimeout(() => {
            $.post(`https://${GetParentResourceName()}/adminRequests`,JSON.stringify({}),function(requestList){
              showAdminRequests(requestList); 
            });    
          }, 500);   
          break;
        case 'submit':
          $.post(`https://${GetParentResourceName()}/submitRequest`, JSON.stringify(formData)); 
          form[0].reset();
          setTimeout(() => {
            $.post(`https://${GetParentResourceName()}/playerRequests`,JSON.stringify({}),function(requestList){
              showPlayerRequests(requestList); 
            });    
          }, 500);
          break;
      }      
    } else {
      form[0].reportValidity();
    }
  })

  var close = function() {
    $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));    
  }
  document.onkeyup = function (data) {
    if (data.which == 27) {
      close();
    }
  }
});
