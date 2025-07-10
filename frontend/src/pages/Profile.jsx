import { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Key, Check, X } from 'lucide-react';

function Profile() {
  const { user, updateApiKeys } = useAuth();
  const [anthropicApiKey, setAnthropicApiKey] = useState('');
  const [openaiApiKey, setOpenaiApiKey] = useState('');
  const [showApiKeys, setShowApiKeys] = useState(false);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  const handleSaveApiKeys = async () => {
    setSaving(true);
    setMessage({ type: '', text: '' });

    const result = await updateApiKeys(anthropicApiKey, openaiApiKey);
    
    if (result.success) {
      setMessage({ type: 'success', text: 'API keys updated successfully!' });
      setAnthropicApiKey('');
      setOpenaiApiKey('');
      setShowApiKeys(false);
    } else {
      setMessage({ type: 'error', text: result.error });
    }
    
    setSaving(false);
  };

  const handleClearApiKeys = async () => {
    if (!confirm('Are you sure you want to clear your custom API keys? The app will use default keys.')) {
      return;
    }

    setSaving(true);
    const result = await updateApiKeys('', '');
    
    if (result.success) {
      setMessage({ type: 'success', text: 'API keys cleared successfully!' });
    } else {
      setMessage({ type: 'error', text: result.error });
    }
    
    setSaving(false);
  };

  return (
    <div className="max-w-2xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-light text-gray-800 mb-8">Profile Settings</h1>

      {/* User Info */}
      <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
        <h2 className="text-lg font-medium text-gray-900 mb-4">Account Information</h2>
        <dl className="space-y-3">
          <div>
            <dt className="text-sm font-medium text-gray-500">Email</dt>
            <dd className="mt-1 text-sm text-gray-900">{user?.email}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Member Since</dt>
            <dd className="mt-1 text-sm text-gray-900">
              {user?.created_at && new Date(user.created_at).toLocaleDateString()}
            </dd>
          </div>
        </dl>
      </div>

      {/* API Keys */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Key className="w-5 h-5 text-gray-500" />
            <h2 className="text-lg font-medium text-gray-900">API Keys</h2>
          </div>
          <div className="flex items-center gap-2 text-sm">
            {user?.has_custom_api_keys ? (
              <>
                <Check className="w-4 h-4 text-green-500" />
                <span className="text-green-600">Custom keys active</span>
              </>
            ) : (
              <>
                <X className="w-4 h-4 text-gray-400" />
                <span className="text-gray-500">Using default keys</span>
              </>
            )}
          </div>
        </div>

        <p className="text-sm text-gray-600 mb-4">
          Add your own API keys to use instead of the app's default keys. Your keys are encrypted and stored securely.
        </p>

        {message.text && (
          <div className={`mb-4 p-3 rounded-md text-sm ${
            message.type === 'success' 
              ? 'bg-green-50 text-green-700 border border-green-200' 
              : 'bg-red-50 text-red-700 border border-red-200'
          }`}>
            {message.text}
          </div>
        )}

        {!showApiKeys ? (
          <div className="flex gap-2">
            <button
              onClick={() => setShowApiKeys(true)}
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors text-sm"
            >
              {user?.has_custom_api_keys ? 'Update API Keys' : 'Add API Keys'}
            </button>
            {user?.has_custom_api_keys && (
              <button
                onClick={handleClearApiKeys}
                disabled={saving}
                className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors text-sm disabled:opacity-50"
              >
                Clear API Keys
              </button>
            )}
          </div>
        ) : (
          <div className="space-y-4">
            <div>
              <label htmlFor="anthropic-key" className="block text-sm font-medium text-gray-700 mb-1">
                Anthropic API Key
              </label>
              <input
                id="anthropic-key"
                type="password"
                value={anthropicApiKey}
                onChange={(e) => setAnthropicApiKey(e.target.value)}
                placeholder="sk-ant-..."
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
              <p className="mt-1 text-xs text-gray-500">
                Get your key from <a href="https://console.anthropic.com" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-700">console.anthropic.com</a>
              </p>
            </div>

            <div>
              <label htmlFor="openai-key" className="block text-sm font-medium text-gray-700 mb-1">
                OpenAI API Key
              </label>
              <input
                id="openai-key"
                type="password"
                value={openaiApiKey}
                onChange={(e) => setOpenaiApiKey(e.target.value)}
                placeholder="sk-..."
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
              <p className="mt-1 text-xs text-gray-500">
                Get your key from <a href="https://platform.openai.com" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-700">platform.openai.com</a>
              </p>
            </div>

            <div className="flex gap-2">
              <button
                onClick={handleSaveApiKeys}
                disabled={saving || (!anthropicApiKey && !openaiApiKey)}
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors text-sm disabled:opacity-50"
              >
                {saving ? 'Saving...' : 'Save API Keys'}
              </button>
              <button
                onClick={() => {
                  setShowApiKeys(false);
                  setAnthropicApiKey('');
                  setOpenaiApiKey('');
                  setMessage({ type: '', text: '' });
                }}
                className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors text-sm"
              >
                Cancel
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Profile;