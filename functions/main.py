from firebase_functions import https_fn
from firebase_admin import firestore, initialize_app
import datetime

initialize_app()
db = firestore.client()

@https_fn.on_request()
def check_token_and_forward_data(request):
    """
    Cloud Function to check token and forward data.
    """
    if request.method != 'POST':
        return 'Invalid method', 405

    token = request.args.get('token')
    if not token:
        return 'Token not provided', 400

    tokens_ref = db.collection('tokens').document(token)
    token_doc = tokens_ref.get()

    if not token_doc.exists:
        return 'Token not found', 404

    token_data = token_doc.to_dict()
    
    last_used = token_data.get('last_used')
    request_count = token_data.get('request_count', 0)
    current_time = datetime.datetime.now()

    if last_used:
        time_diff = current_time - datetime.datetime.strptime(last_used, '%Y-%m-%d')
        if time_diff.days >= 1:
            request_count = 0
        elif request_count >= 5:
            return 'Rate limit exceeded', 429

    tokens_ref.update({
        'last_used': current_time.strftime('%Y-%m-%d'),
        'request_count': request_count + 1
    })

    return 'Data forwarded successfully', 200
