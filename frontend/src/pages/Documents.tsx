import { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { ArrowLeft, Upload, FileText, Download, Trash2, Eye, CircleAlert as AlertCircle, Calendar } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { fetchDocuments, uploadDocument, deleteDocument, downloadDocument } from '../services/documentService';
import { fetchVehicle } from '../services/vehicleService';
import type { Document, Vehicle } from '../types';

const documentTypes = [
  { value: 'rc', label: 'Registration Certificate (RC)' },
  { value: 'insurance', label: 'Insurance' },
  { value: 'permit', label: 'Permit' },
  { value: 'fitness', label: 'Fitness Certificate' },
  { value: 'pollution', label: 'Pollution Certificate' },
  { value: 'road_tax', label: 'Road Tax Receipt' },
  { value: 'other', label: 'Other' },
];

function getExpiryState(dateString: string | undefined) {
  if (!dateString) return 'missing';
  const expiry = new Date(dateString);
  const now = new Date();
  const diffDays = Math.ceil((expiry.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

  if (diffDays < 0) return 'expired';
  if (diffDays <= 30) return 'warning';
  return 'valid';
}

export function Documents() {
  const { vehicleId } = useParams<{ vehicleId: string }>();
  const navigate = useNavigate();
  const [vehicle, setVehicle] = useState<Vehicle | null>(null);
  const [documents, setDocuments] = useState<Document[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [uploadModalOpen, setUploadModalOpen] = useState(false);
  const [uploading, setUploading] = useState(false);

  const [documentType, setDocumentType] = useState('rc');
  const [documentName, setDocumentName] = useState('');
  const [expiryDate, setExpiryDate] = useState('');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);

  useEffect(() => {
    async function loadData() {
      if (!vehicleId) return;
      setLoading(true);
      setError('');
      try {
        const [vehicleData, documentsData] = await Promise.all([
          fetchVehicle(vehicleId),
          fetchDocuments(vehicleId),
        ]);
        setVehicle(vehicleData);
        setDocuments(documentsData);
      } catch (err) {
        setError('Failed to load documents');
      } finally {
        setLoading(false);
      }
    }

    loadData();
  }, [vehicleId]);

  async function handleUpload(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedFile || !vehicleId) return;

    setUploading(true);
    try {
      await uploadDocument(selectedFile, vehicleId, documentType, documentName || documentTypes.find(t => t.value === documentType)?.label || 'Document', expiryDate || undefined);
      const documentsData = await fetchDocuments(vehicleId);
      setDocuments(documentsData);
      setUploadModalOpen(false);
      setSelectedFile(null);
      setDocumentName('');
      setExpiryDate('');
    } catch (err) {
      setError('Failed to upload document');
    } finally {
      setUploading(false);
    }
  }

  async function handleDelete(doc: Document) {
    if (!window.confirm(`Delete "${doc.documentName}"?`)) return;

    try {
      await deleteDocument(doc.id);
      setDocuments((prev) => prev.filter((d) => d.id !== doc.id));
    } catch (err) {
      setError('Failed to delete document');
    }
  }

  async function handleDownload(doc: Document) {
    try {
      await downloadDocument(doc);
    } catch {
      setError('Failed to download document');
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center p-12">
        <div className="text-slate-500">Loading...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 rounded-3xl bg-white p-6 shadow-sm sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" onClick={() => navigate('/vehicles')}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back
          </Button>
          <div>
            <h1 className="text-2xl font-semibold text-slate-900">
              Documents - {vehicle?.licensePlate || 'Vehicle'}
            </h1>
            <p className="mt-1 text-sm text-slate-600">
              Manage vehicle documents and certificates
            </p>
          </div>
        </div>
        <Button
          onClick={() => setUploadModalOpen(true)}
          className="bg-primary-600 hover:bg-primary-700"
        >
          <Upload className="mr-2 h-4 w-4" />
          Upload Document
        </Button>
      </div>

      {error && (
        <div className="rounded-2xl bg-red-50 p-4 text-red-700">
          {error}
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {documents.length === 0 ? (
          <div className="col-span-full rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-10 text-center">
            <FileText className="mx-auto h-12 w-12 text-slate-300" />
            <p className="mt-4 text-lg font-semibold text-slate-900">No documents uploaded</p>
            <p className="mt-1 text-sm text-slate-500">Upload vehicle documents like RC, Insurance, Permit, etc.</p>
          </div>
        ) : (
          documents.map((doc) => {
            const expiryState = getExpiryState(doc.expiryDate);
            const expiryClass =
              expiryState === 'expired'
                ? 'bg-red-100 text-red-700'
                : expiryState === 'warning'
                ? 'bg-amber-100 text-amber-700'
                : 'bg-slate-100 text-slate-500';

            return (
              <div key={doc.id} className="rounded-2xl border border-slate-200 bg-white p-4">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-100">
                      <FileText className="h-5 w-5 text-primary-600" />
                    </div>
                    <div>
                      <h3 className="font-medium text-slate-900">{doc.documentName}</h3>
                      <p className="text-sm text-slate-500 capitalize">{doc.documentType.replace('_', ' ')}</p>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <Button variant="ghost" size="sm" onClick={() => handleDownload(doc)}>
                      <Download className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="sm" onClick={() => window.open(doc.fileUrl, '_blank')}>
                      <Eye className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="sm" className="text-red-600 hover:bg-red-50" onClick={() => handleDelete(doc)}>
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
                {doc.expiryDate && (
                  <div className="mt-3 flex items-center gap-2">
                    <Calendar className="h-4 w-4 text-slate-400" />
                    <span className="text-sm text-slate-600">
                      Expires: {new Date(doc.expiryDate).toLocaleDateString()}
                    </span>
                    <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${expiryClass}`}>
                      {expiryState === 'expired' ? 'Expired' : expiryState === 'warning' ? 'Expiring Soon' : 'Valid'}
                    </span>
                  </div>
                )}
                <div className="mt-2 text-xs text-slate-400">
                  Uploaded: {new Date(doc.createdAt).toLocaleDateString()}
                </div>
              </div>
            );
          })
        )}
      </div>

      {uploadModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/40 px-4 py-6">
          <div className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl">
            <h2 className="mb-4 text-xl font-semibold text-slate-900">Upload Document</h2>
            <form onSubmit={handleUpload} className="space-y-4">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Document Type</span>
                <select
                  className="w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm"
                  value={documentType}
                  onChange={(e) => setDocumentType(e.target.value)}
                >
                  {documentTypes.map((type) => (
                    <option key={type.value} value={type.value}>
                      {type.label}
                    </option>
                  ))}
                </select>
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Document Name</span>
                <input
                  type="text"
                  className="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm"
                  value={documentName}
                  onChange={(e) => setDocumentName(e.target.value)}
                  placeholder={documentTypes.find(t => t.value === documentType)?.label}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Expiry Date (optional)</span>
                <input
                  type="date"
                  className="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm"
                  value={expiryDate}
                  onChange={(e) => setExpiryDate(e.target.value)}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">File</span>
                <input
                  type="file"
                  accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                  className="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm file:mr-4 file:rounded-full file:border-0 file:bg-primary-50 file:px-4 file:py-2 file:text-sm file:text-primary-700 file:hover:bg-primary-100"
                  onChange={(e) => setSelectedFile(e.target.files?.[0] || null)}
                  required
                />
              </label>
              <div className="flex gap-3">
                <Button type="button" variant="secondary" onClick={() => setUploadModalOpen(false)} className="flex-1">
                  Cancel
                </Button>
                <Button type="submit" className="flex-1 bg-primary-600 hover:bg-primary-700" disabled={uploading || !selectedFile}>
                  {uploading ? 'Uploading...' : 'Upload'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
