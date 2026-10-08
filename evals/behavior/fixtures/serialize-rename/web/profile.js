export async function loadProfile(fetchJson, id) {
  const data = await fetchJson(`/api/users/${id}`);
  return { id: data.userId, label: data.name.toUpperCase() };
}
