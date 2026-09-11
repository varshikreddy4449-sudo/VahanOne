import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import type { Document } from '../types';

interface DocumentRow {
  id: number;
  organization_id: string;
  vehicle_id: number | null;
  document_type: string;
  document_name: string;
  file_url: string;
  file_size: number | null;
  mime_type: string | null;
  expiry_date: string | null;
  uploaded_by: string | null;
  created_at: string;
  updated_at: string;
}

function mapDocumentResponse(row: DocumentRow): Document {
  return {
    id: String(row.id),
    vehicleId: row.vehicle_id ? String(row.vehicle_id) : undefined,
    documentType: row.document_type,
    documentName: row.document_name,
    fileUrl: row.file_url,
    fileSize: row.file_size || undefined,
    mimeType: row.mime_type || undefined,
    expiryDate: row.expiry_date || undefined,
    uploadedBy: row.uploaded_by || undefined,
    createdAt: row.created_at,
  };
}

export async function fetchDocuments(vehicleId?: string): Promise<Document[]> {
  let query = supabase
    .from('documents')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('created_at', { ascending: false });

  if (vehicleId) {
    query = query.eq('vehicle_id', parseInt(vehicleId, 10));
  }

  const { data, error } = await query;

  if (error) {
    console.error('Error fetching documents:', error);
    throw new Error('Failed to fetch documents');
  }

  return (data || []).map(mapDocumentResponse);
}

export async function uploadDocument(
  file: File,
  vehicleId: string,
  documentType: string,
  documentName: string,
  expiryDate?: string
): Promise<Document> {
  const fileExt = file.name.split('.').pop();
  const fileName = `${DEFAULT_ORG_ID}/${vehicleId}/${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`;

  const { error: uploadError } = await supabase.storage
    .from('documents')
    .upload(fileName, file);

  if (uploadError) {
    console.error('Error uploading document:', uploadError);
    throw new Error('Failed to upload document');
  }

  const { data: { publicUrl } } = supabase.storage
    .from('documents')
    .getPublicUrl(fileName);

  const { data, error } = await supabase
    .from('documents')
    .insert({
      organization_id: DEFAULT_ORG_ID,
      vehicle_id: parseInt(vehicleId, 10),
      document_type: documentType,
      document_name: documentName,
      file_url: publicUrl,
      file_size: file.size,
      mime_type: file.type,
      expiry_date: expiryDate || null,
    })
    .select()
    .single();

  if (error) {
    console.error('Error creating document record:', error);
    throw new Error('Failed to create document record');
  }

  return mapDocumentResponse(data);
}

export async function deleteDocument(documentId: string): Promise<void> {
  const { data: doc, error: fetchError } = await supabase
    .from('documents')
    .select('file_url')
    .eq('id', parseInt(documentId, 10))
    .single();

  if (fetchError) {
    console.error('Error fetching document:', fetchError);
    throw new Error('Failed to fetch document');
  }

  if (doc?.file_url) {
    const url = new URL(doc.file_url);
    const pathParts = url.pathname.split('/');
    const filePath = pathParts.slice(-3).join('/');

    await supabase.storage.from('documents').remove([filePath]);
  }

  const { error } = await supabase
    .from('documents')
    .delete()
    .eq('id', parseInt(documentId, 10));

  if (error) {
    console.error('Error deleting document:', error);
    throw new Error('Failed to delete document');
  }
}

export async function downloadDocument(document: Document): Promise<void> {
  const response = await fetch(document.fileUrl);
  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  const a = document.documentName || window.document.createElement('a');
  if (a === window.document.createElement('a')) {
    a.href = url;
    a.download = document.documentName || 'document';
    window.document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    a.remove();
  } else {
    window.open(url, '_blank');
  }
}
